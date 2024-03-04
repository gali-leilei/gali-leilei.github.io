+++
title = "Sampling A Skewed Distribution"
date = 2023-04-21
+++

## Motivation

To answer this question:

How to sample from a distribution given its mean $mu$, variance $\sigma^2$ and skewness $s$?

When skewness is zero, the problem reduces to sampling from normal distribution. Surely it is easy to extend it for $s \neq 0$, right?
The answer from chatGPT looked promising, but failed to simulation for skewness outside of [-1, 1].

Several iteration later, the question becomes:

What is the maximum entropy distribution, given its first $k$ moments?

Much of this post is from the paper [Entropy Densities](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1730203) with an implementation in Python at the end.

## Exact Solution

It turns out that there is an exact solution to the above problem:

$$p \in argmax - \int_{x \in D} p(x) \log(p(x)) dx$$

where $D$ is some convex domain, $\int_{x \in D} p(x) dx = 1$ and $\int_{x \in D} x^i p(x) dx = b_i$ for $i = 1, \ldots, m$.

Claim 1: The solution has the form $p(x) = \frac{1}{Q(\lambda)} \exp(\sum_{i=1}^m \lambda_i (x^i - b_i))$ for some number $\lambda = (\lambda_1, \ldots, \lambda_m) \in \mathbb{R}^m$, where the normalization constant is $Q(\lambda) = \int_D \exp(\sum_{i =1}^m (x^i - b_i)) dx$.

Proof: see equation (8) from the paper.

Claim 2: The minimization of $Q(\lambda)$ yields a density satisfying the moment constraints.

Proof: see page 5 from above paper.

If only the first moment is specified, we have an exponential distribution.

If only the first two moments are specified, we have a normal distribution.

In all other cases, there is no closed form expression; now we turn to numeric approximation, exploiting Claim 2.

## Numerical Approximation

What is left are:

1. a numerical recipe for computation of $Q(\lambda)$ over $D$ given $\lambda \in \mathbb{R}^m$.
2. sampling from the given distribution $p(x)$ given $\lambda$.

For the first part, the code leverages `np.polynomial.legendre.leggauss` for Lengendre-Gauss integral, and `scipy.optimize.minimize` for Newton method.

```python
import numpy as np
import scipy

def vandermonde_matrix(points, degree, skip_first_col=False):
    points = points.reshape(-1, 1)
    start_idx = 1 if skip_first_col else 0
    powers = np.arange(start_idx, degree + 1)
    return np.power(points, powers)


class MaxEntropyPDFSolver(object):
    """This class implements the solver for probability density function (PDF)
    from this paper:
    ENTROPY DENSITIES: WITH AN APPLICATION TO AUTOREGRESSIVE CONDITIONAL SKEWNESS AND KURTOSIS

    """

    def __init__(self, moments, bounds, degree, num_point=40):
        self.moments = moments
        self.bounds = bounds
        self.degree = degree
        self.num_point = num_point

    def _get_quadrature(self, n, degree, bounds):
        low, high = bounds
        z, w = np.polynomial.legendre.leggauss(n)
        x = (high - low) / 2 * z + (low + high) / 2
        x_mat = vandermonde_matrix(x, degree, skip_first_col=True)
        return x_mat, w

    def _make_objective(self, x_mat, weights, moments):
        x_pow = np.array(x_mat)
        w = np.array(weights)
        b = np.array(moments)

        def objective(x):
            A = x_pow - b
            y = np.dot(np.exp(A @ x), w)
            return y

        return objective

    def _make_jacobian(self, x_mat, weights, moments):
        x_pow = np.array(x_mat)
        w = np.array(weights)
        b = np.array(moments)

        def jacobian(x):
            A = x_pow - b
            grad = A.T @ (w * np.exp(A @ x))
            return grad

        return jacobian

    def solve(self):
        quad_x, quad_w = self._get_quadrature(self.num_point, self.degree, self.bounds)
        obj = self._make_objective(quad_x, quad_w, self.moments)
        jac = self._make_jacobian(quad_x, quad_w, self.moments)
        x0 = np.zeros(self.degree)
        result = scipy.optimize.minimize(obj, x0, jac=jac)
        return result.x
```

For the second part, the gist is to use rejection sampling from the region $D \times h$, where $h = \max_{x \in D} p(x)$.
There are some missing details of converting centered moments $\int_D (x - m_1)^2 p(x) dx = m_i$ to uncentered moments $\int_D x^i p(x) dx = b_i$, in the construction of $p(x)$.

```python
import numpy as np
import scipy

def find_max(fn, bounds):
    """find the maximum of a scalar fn on a finite interval"""
    res = scipy.optimize.minimize_scalar(
        lambda x: -fn(x), bounds=bounds, method="bounded"
    )
    return -res.fun


def integrate(fn, bounds, n_points=100):
    low, high = bounds
    width = (high - low) / n_points
    x = np.linspace(low, high, n_points)
    answer = np.sum(fn(x)) * width
    return answer


def sample(pdf, bounds, n_sample):
    """generates `n_sample` datapoint given the distribution"""
    low, hi = bounds
    pdf_max = find_max(pdf, bounds)
    pdf_area = integrate(pdf, bounds)
    acceptance_rate = pdf_area / ((hi - low) * pdf_max)
    x_rv = scipy.stats.uniform(loc=low, scale=hi - low)
    y_rv = scipy.stats.uniform(loc=0, scale=pdf_max)
    print("acceptance rate is ", acceptance_rate)

    # sample in a loop;
    result = np.zeros(n_sample)
    needed, idx = n_sample, 0
    while needed > 0:
        n_draw = int(0.5 * needed / acceptance_rate)
        xs = x_rv.rvs(size=n_draw)
        ys = y_rv.rvs(size=n_draw)
        accept_idx = ys < pdf(xs)
        batch = xs[accept_idx]
        buffer_size = min(len(batch), needed)
        result[idx : idx + buffer_size] = batch[:buffer_size]
        idx = idx + buffer_size
        needed = needed - buffer_size
    return result
```
