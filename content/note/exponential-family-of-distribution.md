+++
title = "What is Exponential Family of Distribution"
date = 2021-05-13
+++

## Motivation

To understand the first 4 page of [Generalized Linear Models][glm-paper] by Nelder and Wedderburn, without a formal background in Statistics. That took me a while.

[This 4 hours lecture series][mit-glm-video] from MIT helped a lot. Highly recommend.

By the end of the post, I hope I have answered this question:

- what is the **intuition** of exponential family of distribution?

## Sufficient Statistics

**Definition** A _statistics_ is a function $T := r(X_1, X_2, \ldots, X_n)$ of the random samples $X_1, X_2, \ldots, X_n \in S$. For now, suppose the samples are sampled from a unknown distribution $\pi$.

**Definition** A _statistical model_ is a pair of $(S, P)$, where $S$ is the set of all possible observation and $P$ is the set of probability distribution on $S$. Note: S for Sample space and P for Prior distributions.

**Definition** Given _statistical model_, $(S, P)$, suppose that $P$ is parameterized: $P := \{P_\theta \mid \theta \in O\}$. Then the model is:

- _parametric_ if $O$ is finite dimensional,
- _non-parametric_ if $O$ is infinite dimensional,
- _semi-parametric_ if $O$ has both finite and infinite dimensional parameters.

That was a mouthful so that I can say the following:

**Definition** Let $(S, P_\theta)$ be a _parametric statistical models_ and $X_1, X_2, \ldots, X_n \in S$ be i.i.d. samples generated from $P_\theta^*$ for some unknown $\theta^* \in O$. An _estimator_ for $\theta^*$, $T(X_1, X_2, \ldots, X_n)$, is a _statistics_ that maps into $O$, i.e. $T: S^n \rightarrow O$.

In general, the true distribution, $\pi$, that generates the samples may not be in the prior $P_\theta$. That should be fine if the set $P_\theta$ is dense enough: for any $\epsilon > 0$, there exists $\theta$ such that $d(P_\theta, \pi) < \epsilon$.

**Definition** Let $(S, P_\theta)$ be a _parametric statistical models_ and $X_1, X_2, \ldots, X_n \in S$ be i.i.d. samples generated from $P_\theta^*$ for some unknown $\theta^* \in O$. A _statistics_, $T(x)$, is **sufficient** if

- no other statistics, $h: S^n \rightarrow O$, provide additional information on $\theta^*$, or
- (Fisher-Neyman factorization) there exists non-negative functions $f: S^n \rightarrow R, g: S^n \rightarrow R$ such that $P_\theta(x) = h(x) g(T(x); \theta)$

Sufficient statistics formalizes [the idea][sufficient-statistics] that, two sets of data yielding the same value for statistics $T(x)$, would yield the same inference about $\theta$. The notion of sufficiency makes most sense in term of information entropy; there is no loss of information regarding $\theta$ when compressing from samples, $X_1, X_2, \ldots, X_n$, to statistics, $T(X_1, X_2, \ldots, X_n)$.

If we were to describe the distribution, a parametric model (distribution as a function of the statistics) is as good as a non-parametric model (distribution as a function of the data points), **if and only if** the distribution admits sufficient statistics.

In layman's term, no information is lost when **compressing** arbitrary n data points (samples) into a fixed number of parameters (statistics).

So what does it have to do with exponential family of distributions?

TODO: use factorization theorem instead, drop the assumption on i.i.d.

## Essence of Exponential Family of Distribution

[It turns out that][koopman-paper], a _sufficient_ condition (not a pun) for distributions admitting a sufficient statistics is that its distribution obeys a certain form:

**Definition** (slide 11 from [MIT course notes][glm-mit-notes]) _exponential family of distribution_ is a parametric distribution where:

A family of distribution $\{P_\theta: \theta \in \Omega \}$, $\Omega \subset \mathbb{R}^k$ is said to be a
$k$ -parameter exponential family on $\mathbb{R}^q$ , if there exist real valued
functions:

- $\mu_1, \mu_2, \ldots, \mu_k$ and $B$ of $\theta$,
- $T_1, T_2, \ldots, T_k$ and $h$ of $x \sub \mathbb{R}^q$ such that the density
  function (pmf or pdf) of $P_\theta$ can be written as

$$
p_\theta(x) := exp \left( \sum_{i = 1}^k \mu_i(\theta) T_i(x) - B(\theta)\right) h(x)
$$

For most practical purposes, $k$ is rarely more than 1. See this chart of commonly used distributions (FIXME: insert taxonomy of various distributions)

## Definition of Canonical Exponential Family of Distribution

**Definition** A exponential family of distribution for $k = 1, x \in \mathbb{R}$ is canonical if

- the parameter $\theta \in \mathbb{R}$ only interacts **linearly** with observation/statistics, or equivalently
- it can be written as $p(x; \theta) = exp(\langle t(x), \theta \rangle) a(x) b(\theta)$, or equivalently
- it has the following canonical decomposition

$$
p(x; \theta) := exp( \langle x, \theta \rangle - F(\theta) + k(x))
$$

where

- $t(x) := x$ is the sufficient statistics being identity function,
- $\theta$ is the natural parameters,
- $F(\cdot)$ is the log-normalizer,
- $k(x)$ is the carrier measure.

### Properties of Canonical Exponential Family of Distribution

The exponential form of pdf allows us to derive mean and variance analytically, which will be useful in discussing Generalized Linear Model.

**Lemma** Let $p(x; \theta)$ be a probability density function with parameter $\theta$ and $l(\theta) := log p(x; \theta)$ be the likelihood function. We have

- $E[\frac{\partial l}{\partial \theta}] = 0$ because

$$
E[\frac{\partial l}{\partial \theta}] := \int \frac{p'(x; \theta)}{p(x; \theta)} p(x; \theta) dx = \int \frac{d}{d \theta} \left( p(x; \theta) \right) dx= \frac{d}{d \theta} \int p(x; \theta) dx = 0
$$

- $E[\frac{\partial l^2}{\partial^2 \theta}] = - E[(\frac{\partial l}{\partial \theta})^2]$ because

$$
E\left[\frac{\partial l^2}{\partial^2 \theta}\right] := E\left[\frac{d}{d \theta}\left(\frac{p'(x; \theta)}{p(x; \theta)}\right)\right] = \int \frac{p''(x; \theta)p(x; \theta) - p'(x; \theta)^2}{p^2(x; \theta)} p(x; \theta)dx = \int p''(x; \theta) dx - \int \left(\frac{p'(x; \theta)}{p(x; \theta)}\right)^2 p(x; \theta) dx = - E\left[\left(\frac{\partial l}{\partial \theta}\right)^2\right]
$$

**Claim** Suppose a distribution $X \sim p(x ; \theta) := exp (x \theta - F(\theta) + k(x))$, then

- $E[X | \theta] := F'(\theta)$ and
- $Var[X | \theta] := F''(\theta)$.

This follows from applying the lemma above.

[glm-paper]: https://repository.rothamsted.ac.uk/download/25425465aa52d05e1a9e553b2daddeeffe15d0ba40f5f9b8937aaab5c3d29e1d/4410096/Nelder%201972.pdf
[mit-glm-video]: https://www.youtube.com/watch?v=X-ix97pw0xY
[sufficient-statistics]: https://www.math.arizona.edu/~tgk/466/sufficient.pdf
[glm-mit-nodes]: https://ocw.mit.edu/courses/mathematics/18-650-statistics-for-applications-fall-2016/lecture-slides/MIT18_650F16_GLM.pdf
[koopman-paper]: http://www.ams.org/journals/tran/1936-039-03/S0002-9947-1936-1501854-3/S0002-9947-1936-1501854-3.pdf
