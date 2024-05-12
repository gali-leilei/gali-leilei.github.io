+++
title = "Optimal Betting Strategy"
date = 2013-12-31
template = "markdown-page.html"
+++


## A Bit of Context...

In 2013, Jump trading posted a challenge problem as part of their college recruiting process. I did part 1 and 2, was given a chance to interview. I did not get the offer, but did get an iPad for [my submission][3].

The challenge problem is [is unreachable now][1] and somehow no other participants have [explored the problem in details on Quora][2]. That is a shame, because it is a deceptively simple problem with an elegant solution.

## Problem description

A gambler is playing against the casino with a coin. Each round, the gambler bet $x$ dollars as he wishes on the coin flips: he gets $2x$ back if head, else nothing. The game ends when either parties goes bankrupt. The constraints are:

- The total amount of money between them is fixed, say $N$.
- The bet is multiples of one dollar, and no more than what the gambler or the casino currently has.
- The coin is biased; the probability of it turning up head is $p = 0.37$.

An betting strategy $s : \mathbb{N} \rightarrow \mathbb{N}$ tells you the amount of bet $s(x)$ given your current winning $x$. It is optimal if for any starting amount $x$ gambler has

- among all possible strategies $s'$, it gives the gambler the highest chace of winning the game (call it a *winning* strategy) and
- the amount it bets is the *smallest* among all *winning* strategies.

(Part 1 of the challenge): Give the optimal strategy for $N = 1000$ and $N = 1,000,000$.

(Part 2 of the challenge): Now the game allow the bet amount to be any real number, and let $N = 1$. Find the optimal betting strategy $s: [0, 1] \rightarrow [0, 1]$.


## Solution


### A Familliar Context

If you happened to know Markov chain, you may recognize its similiarity to gambler's ruin. With the coin biased towards the house, the gambler is at a disdvantage as the game drags on. 

It turns out that the gambler should play as aggressively as possible, betting everything he has each turn. But is that all to this problem?

### A Digression on Existence...

One thing I glossed over, is that *winning* strategy do exists. For any betting strategy $s(x)$, we can define $V_s(x)$, the chance of beating the casino following strategy $s$, starting at $x$. I am claiming that

$$
\exists s, \text{ such that } V_s(x) \geq V_t(x) \text{ for any other strategy } t
$$

If you are interested in the details, have a look [my submission for part 2][3]. I spend the first 5 pages proving this, assuming a background of linear algebra and markov chain.

### Finding the Strategy

Any reinforcement learning algorithm will do, for example [Policy Iteration][4] or [Value Iteration][5] (I came around to these in a roundabout way, I will write about them in another post). If you run value iteration first, you will note that:

1. The aggressive play is a *winning* play,
2. There are other strategies, which bet less and achieve the same winrate.

If you run the policy iteration on $N = 2^m$, you will notice something strange: the smallest amount to bet for $x = 2^k y$ is $2^k$. This has the same payoff as all-out aggresive play.

### Part II: For Arbitrary Input

Part II extends state and action space to all real number between 0 and 1. Running either policy/value iteration would be infeasible. The alternative, is to leverage the previous observation and extend it to all real number. This turns out to be much easier: induction on recurrence relation would suffice, as shown in [page 6 and 7 here][3].

[1]: https://www.jumptrading.com/challenge
[2]: https://www.quora.com/What-is-the-solution-to-the-2013-Jump-Trading-challenge
[3]: /jump.pdf
[4]: https://en.wikipedia.org/wiki/Markov_decision_process#Policy_iteration
[5]: https://en.wikipedia.org/wiki/Markov_decision_process#Value_iteration