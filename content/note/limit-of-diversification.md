+++
  title = "Limit of Diversification"
  date = 2023-07-21
+++

## Motivation

Nobel prize laureate Harry Markowitz famously said that **diversification is the only free lunch** in investing. This note shows that limit of free lunch.

The limit is demostrated in two interview questions from [Quantitative Portfolio Management](TODO) Chapter 3.1/3.2 (there are spherical-cow type of questions; don't read too much into them!):

> A hedge fund has built a thousand strategies such that each two are 10% correlated with each other. Estimate how many effectively independent strategies the fund really has.

The answer is $\frac{1000}{101} \approx 9.9$. In general, the effective number of indepedent strategies is upper bounded by the inverse of pairwise correlations among a pool of strategies.

> Given two strategies with uncorrelated pnl time series and Sharpe ratio 3.0 and 4.0, what is the maximum possible Sharpe of the combined portfolio?

The answer is $\sqrt{3^2 + 4^2} = 5$. There is a nice geometric interpretation.

## First Question

We first take a digression to consider linearly combining strategies:

Assume a normally distributed return $x \sim \mathfrak{N}(\mu, C)$ for N strategies, where $C_{ii} = 1$.

If we combine the strategies by taking an average of them (i.e. basically investing equal amount of money in every strategy), what is the sharpe ratio of the combined strategies?

Well, consider the following two scenenarios

- N independent portfolios, i.e, $C_{ij} = 0$ whenever $i \neq j$.
- N weakly-correlated portfolios, i.e $C_{ij} = \rho$ whenever $i \neq j$.

Under both cases, the expected return is the same:

$$\bar{x} =\frac{1}{N}\sum_i x_i \quad E[\bar{x}] = \bar{\mu} = \frac{1}{N} \sum_i \mu_i$$

However, the variance and sharpe ratio for independent strategies:

$$Var(\bar{x}) = \frac{1}{N^2}\sum_{ij} C_{ij} = \frac{1}{N}$$

$$Sharpe(\bar{x}) = \frac{Mean(\bar{x})}{Var^{1/2}(\bar{x})} = \bar{\mu} \sqrt{N}$$

is different from those for weakly correlated strategies:

$$Var(\bar{x}) = \frac{1}{N^2}\sum_{ij} C_{ij} = \frac{1 + \rho(N - 1)}{N} > \rho$$

$$Sharpe(\bar{x}) = \frac{Mean(\bar{x})}{Var^{1/2}(\bar{x})} = \bar{\mu} \sqrt{\frac{N}{1 + \rho(N - 1)}} < \frac{\bar{\mu}}{\sqrt{\rho}}$$

Back to the original question, where $N = 1000$ and $\rho = 0.1$. Let the effective number of independent strategies be $N_{eff}$, then

$$\bar{\mu} \sqrt{N_{eff}} = \bar{\mu} \sqrt{\frac{N}{1 + \rho(N - 1)}}$$

which gives $N_{eff} = \frac{N}{1 + \rho(N - 1)} = \frac{1000}{101} \approx 10$.

## Second Question

This is a special case of mean-variance optimization for $N = 2$. What is interesting here though, is that after all the algebra done (see the book linked above for what the symbol means!), a nice geometric interpretation of the formula below:

$$S^2 = \frac{E(Q)^2}{Var(Q)} = \frac{S_1^2 - 2 \rho S1 S2 + S_2^2}{1 - \rho^2}$$

If $S_1$ and $S_2$ are the sides of a triangle, and $rho$ is the cosine of the angle between them:

- the numerator is the cosine law, giving the third sidelength
- the denominator is the sine of the angle between them

by sine law, $S$ the diameter of the circumscribed circle of the triangle.
