+++
title = "TIL Max/Min Search and an Interesting Puzzle"
date = 2023-01-23
+++

## Motivation

The goal of this note is to have a **simple** implementation of max-search and min-search algorithm in **Python**.

Why do I need this? There are quite a number of search problems for [advent-of-code 2022](https://adventofcode.com/2022), and normally I would Google `python dijkstra/dfs/bfs/`. Implementation on Wikipedia has a rather large memory footprint though, with its main search algorithm tangled with data structure. I stumbled upon [A-star-search][cpablo-repo] by Python core developer [cpablosga](), which is the best implementation of min-search I have seen so far. I like it enough, so I will extend it to do max-search as well (see [this paper][TODO]).

## Min Search

Assumes the problem has a optimal sub-structure. Use A-\* if `lower_bound()` is available; else use uniform cost search (logical equivalent to Dijkstra's algorithm).

```python
from collections import namedtuple

node = namedtuple('Node', 'cost point came_from')

def min_search(start: Point, is_end: Callable[[Point], bool]):
    frontier = DijkstraHeap(Node(0, start))

    while frontier:
        curr = frontier.pop()

        if is_target(curr.node):
            return frontier

        for edge_cost, node in gen_nbh(curr):
            new_cost = new_cost + edge_cost + lower_bound(node)

            new_node = Node(cost=new_cost, point = node, came_from = curr)

            frontier.insert(new_node)

class DijkstraHeap(list):
    def __init__(self, start: Node):
        self.visited = dict()
        self.cost = dict()
        if start is not None:
            self.append(start)

    def insert(self, node):
        if node not in self.visited:
            heapq.heappush(self)

    def pop(self):
        while self and self[0].point in visited:
            heapq.heappop(self)

        if self:
            next_elem = heapq.heappop(self)
            self.visited[next_elem.point] = next_elem.came_from
            self.cost[next_elem.point] = next_elem.cost
            return next_elem
```

A few notes:

- the standard terminology is **open/visited set** in uniform cost search. I will stick to it (the code use `frontier` because `open` is a Python keyword).
- **No comparison operator here**. It is possible because whenever we remove a node from the open set, it is guaranteed to be the first time we see it and the cost is minimal.
- Modular. The core idea of `check the best-guess from open set` is orthogonal to `how to remove/add element to open set`; so is the implementation here.

## Max Search

Use Branch-and-Bound if `upper_bound()` is available; else it iterates over all candidates.

```python
from collections import namedtuple

node = namedtuple('Node', 'profit point came_from')

def max_search(start: Point):
    frontier = SearchSpace(Node(profit=0, point=start, came_from=None))

    while frontier:
        curr = frontier.pop()

        for action_reward, node in gen_nbh(curr):
            new_profit = action_reward + curr.profit
            new_bound = new_profit + upper_bound(node)
            new_node = Node(profit=new_profit, point = node, came_from = curr)

            frontier.insert(new_node, bound=new_bound)

    return frontier

class SearchSpace(list):
    def __init__(self, start: Node):
        self.visited = set()
        self.cost = dict()
        self.best_val = -float('inf')

    def insert(self, node, bound=None):
        if bound is not None and bound < self.best_val:
            return
        self.append(node)

    def pop(self):
        if not self:
            return
        node = self.pop()
        if node.profit > self.best_val:
            self.best_val = node.profit
        self.profit[node.point] = node.profit
        self.visited[node.point] = node.came_from
        return node
```

A few notes:

- Use `profit` instead of `cost`, as we are maximizing a quantity instead of minimizing.
- One can use a max-heap instead of a plain array. Either way the open set should be exhausted.

## Lesses More Puzzle

This is from [Jane Street Jan 2023](https://www.janestreet.com/puzzles/lesses-more-index/).

Problem statement:
given non-negative integers a, b, c, d, define two function f and g as:

g(a, b, c, d) = (abs(a - b), abs(b - c), abs(c - d), abs(d - a))

f(a, b, c, d) = min(n such that $g^n(a, b, c, d) = (0, 0, 0, 0)$)

Now consider all 4-tuple where each element is less than 1 million. Find the one tuple with the maximum value of $f(a, b, c, d)$; in case of ties, return the one with smallest total sum.

### The Strategy

The [official solution](https://www.janestreet.com/puzzles/lesses-more-solution/) is quite clever; it transforms the problem into finding a fixed point of a function over $$\mathbb{R}^4$$.

Another strategy is to brute force it with max-search outlined above. We start from the end (0, 0, 0, 0) and build a weighted directed graph from it:

- $g(a_1, b_1, c_1, d_1) = (a_2, b_2, c_2, d_2)$, then we have a directed edge $((a_2, b_2, c_2, d_2) \rightarrow (a_1, b_1, c_1, d_1))$ with cost 1.
- we could exploit symmetry to prune the search space. For example $g(a, b, c, d) = g(a, d, c, b)$ due to rotation symmetry. $g(a, b, c, d) = g(b, c, d, a)$ due to reflection symmetry. $g(a, b, c, d) = g(a + m, b + m, c + m, d + m)$ from definition. These edges have edge cost 0.
- the search problem can then be broken into two steps:
  - find the set of longest paths starting from (0, 0, 0, 0) under the constraint, and
  - sort them by the sum of 4-tuple at the end of the path.

The second step is easier. The first step begs the following questions:

- Q1. which node(s) to start from (variable `start`)?
- Q2. how to implement `def gen_nbr`?
- Q3. how to implement `def upper_bound`?

### Which Node To Start From

The obvious answer is `(0, 0, 0, 0)`. But then $(x, x, x, x) \leftarrow (0, 0, 0, 0)$, for all x <= N. That is too many to search.

The first insight came from observing the optimal solution for $N = 100$. Note how power of 2 doubles every 4 iteration:

```text
(0, 7, 20, 44) <- 1 | gcd
(7, 13, 24, 44)
(6, 11, 20, 37)
(5, 9, 17, 31)
(4, 8, 14, 26) <- 2 | gcd
(4, 6, 12, 22)
(2, 6, 10, 18)
(4, 4, 8, 16) <- 4 | gcd
(0, 4, 8, 12)
(4, 4, 4, 12)
(0, 0, 8, 8)
(0, 8, 0, 8) <- 8 | gcd
(8, 8, 8, 8)
(0, 0, 0, 0)
```

It turns out that is true for all sequences.

Claim 1. Let $\alpha, \beta, \gamma, \delta = g^4(a, b, c, d)$. If $2^k | gcd(a, b, c, d)$, then $2^{k + 1} | gcd(\alpha, \beta, \gamma, \delta)$

Proof:

$$-x \equiv x \equiv |x| (\mod 2)$$

We can drop the abs when doing modulo 2, and freely choose sign:

$$
(a, b, c, d) \leftarrow (a - b, b - c, c - d, d - a) \leftarrow (a + c, b + d, a + c, b + d) \leftarrow (x, x, x, x) \leftarrow (0, 0, 0, 0)
$$

where $$x = a + c + b + d$$.

QED

From Claim 1, it suffices to check $(x, x, x, x)$ where $x = 2^k$.

### Implementing `gen_nbr`

This boils down to iterate over edge with cost 0 and 1, for 4-tuple $(a, b, c, d)$:

- for edge with cost 1, there musts exists an choice of signs $s_i \in \{-1, 1\}, i = \{1,2,3,4\}$, such that $s_1 a + s_2 b + s_3 c + s_4 d = 0$.
- for edge with cost 0, it suffices to implement only $(a, b, c, d) \leftarrow (a + m, b + m, c + m, d + m)$.

To see why we need the second set of edges, consider how to reach $(4, 4, 4, 12)$ from $(0, 0, 8, 8)$. (Hint: $(0, 0, 8, 8) \rightarrow (0, 0, 0, 8) \rightarrow (4, 4, 4, 12)$)

### How to Implement `upper_bound`

The upper bound function follows from Claim 1. If $2^k | gcd(a, b, c, d)$, the longest path is upper bounded by $4(k + 1)$.

### Appendix: Python Solution

Putting all the above together, we have the following script:

```python
import math

from typing import NamedTuple, Iterable, Tuple
from collections import namedtuple
from functools import product

Point = namedtuple('Point', 'a b c d')
Node = namedtuple('Node', 'profit point came_from')

point_sum = lambda s: sum(s)
point_min = lambda s: min(s)
point_max = lambda s: max(s)
add_float = lambda s, f: Point(*(f + x for x in s))
dot_prod = lambda s1, s2: sum(x * y for x, y in zip(s1, s2))

# how we advance state
def g(s: Point):
    return Point(abs(s.a - s.b), abs(s.b - s.c), abs(s.c - s.d), abs(s.d - s.a))

def solve(lst: Iterable[int], sign: Iterable[int]) -> Point:
    result = [0] * 4
    for i in range(3):
        result[i] = result[i - 1] - sign[i - 1] * lst[i - 1]
    floor = min(result)
    if floor < 0:
        result = [x - floor for x in result]
    return Point(*result)

# iterate over all 2^4 = 16 possible sign combination
def gen_sign():
    signs = (-1, 1)
    for a, b, c, d in product(signs, signs, signs, signs):
        result = Point(a, b, c, d)
        yield result, point_sum(result)

def gen_nbh(curr: Point) -> Tuple[int, Point]:
    for sign, sign_sum in gen_sign():
        if sign_sum in (-4, 4):
            continue
        curr_sum = dot_prod(curr, sign)
        if curr_sum == 0:
            prev = solve(curr, sign)
            if point_sum(prev) > 0:
                yield 1, prev
        # 3 pos, 1 neg. if all number +m, then
        # curr_sum + 2m = 0 -> m = - dot_prod / 2
        if sign_sum == 2 and curr_sum != 0 and curr_sum % 2 == 0:
            m = - curr_sum // 2
            new_curr = add_float(curr, m)
            if point_min(new_curr) >= 0 and point_max(new_curr) > 0:
                yield 0, new_curr
        # 3 neg, 1 pos, if all number +m, then
        # curr_sum - 2m = 0 -> m = dot_prod / 2
        if sign_sum == -2 and curr_sum != 0 and curr_sum % 2 == 0:
            m = curr_sum // 2
            new_curr = add_float(curr, m)
            if point_min(new_curr) >= 0 and point_max(new_curr) > 0:
                yield 0, new_curr

# helper function for search_max
def upper_bound(s: Point):
    x = math.gcd(s.a, s.b)
    y = math.gcd(s.c, s.d)
    gcd = math.gcd(x, y)
    assert gcd > 0, f"found gcd == 0 for {s}"
    answer = 0
    while True:
        if gcd % (2 << answer) == 0:
            answer += 1
        else:
            return 4 * (answer + 1)
    return None


def max_search(N = 10_000_000):
    frontier = SearchSpace(N)

    while frontier:
        curr = frontier.pop()

        profit, point, _ = curr
        for action_reward, node in gen_nbh(point):
            new_profit = action_reward + profit
            new_bound = new_profit + upper_bound(node)
            new_node = Node(profit=new_profit, point = node, came_from = point)

            frontier.insert(new_node, bound=new_bound)

    return frontier

class SearchSpace(list):
    def __init__(self, N = 10_000_000):
        self.visited = set()
        self.profit = dict()
        self.best_val = -float('inf')
        self.best_point = []

        self.N = N
        x = 2
        while x <= self.N:
            point = Point(x, x, x, x)
            self.insert(Node(profit=2, point=point, came_from=None), bound=2)
            self.visited.add(point)
            self.profit[point] = 2
            x = 2 * x

    def insert(self, node, bound=None):
        if node.point in self.visited:
            return
        if point_max(node.point) > self.N:
            return
        if bound < self.best_val:
            return
        self.append(node)

    def pop(self):
        node = super(SearchSpace, self).pop()
        if node.profit > self.best_val:
            self.best_val = node.profit
            self.best_point.clear()
        if node.profit == self.best_val:
            self.best_val = node.profit
            self.best_point.append(node.point)
        self.profit[node.point] = node.profit
        self.visited.add(node.point)
        return node

def find_smallest_sum(N):
    frontier = max_search(100_000_00)
    smallest = [(point_sum(point), point) for point in frontier.best_point]
    smallest = sorted(smallest)
    return frontier.best_val, smallest[0][0], smallest[0][1]

N = 10_000_000
print(find_smallest_sum(N))
# 20 815 State(a=0, b=81, c=230, d=504) when N = 1_000
# 38 1221623 State(a=0, b=121415, c=344732, d=755476) when N = 1_000_000
# 44 13980895 State(a=0, b=1389537, c=3945294, d=8646064) when N = 10_000_000
```
