+++
title = "Lightweight Recommendation Service"
date = 2024-10-27
template = "markdown-page.html"
+++

# Introduction

[pairec-lite](https://bitbucket.org/galileilei/literec/src/main/) is a stripped-down version of [Alibaba's pairec](https://github.com/alibaba/pairec), with no external dependencies. This repo is more pedagogical than practical.

Here is how one bootstrap a service using `pairec-lite`. 

```go
```

# Why use `pairec` in the first place?

- lack of resources. At first we have one and a half people to develop a recommendation service from scratch. It was not a priority feature.
- lack of experience. Most of the team has no ideas what a recommendation service is. 
- possibility of throwaway software. Due to uncertainty of how long the product can survive, we may not need to pay the high interest rate from the technical debt of using a heavy framework.

# Why should I use `pairec` instead of `pairec-lite`?

In most cases, you should not. I used it at work for several reason:
- `pairec` offers way more than what we use. The infra stack was simply AWS + Postgres, less than 5% of what pairec offers out-of-the-box.
- adapting `pairec` for other uses. These include: adapting `pairec` for search; embedding `pairec` into an existing web service; adding timeout control and streaming responses. Like all frameworks, doing things not the way it intends is a lot of work.
- stripping down dependencies. `pairec` and its transitive  dependencies adds around 30MB after compilation. 