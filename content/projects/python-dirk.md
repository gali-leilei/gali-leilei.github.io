+++
title = "Lightweight DAG execution"
date = 2023-12-31
template = "markdown-page.html"
+++

# Introduction

[python-dirk](https://bitbucket.org/galileilei/python-dirk/src/main/) is a proof-of-concept library, demonstrating a new API for declaring Direct Acylic Graph (DAG) workflow. Here is a snippet, of writing task A -> task B:

```python
from python_dirk import Pipeline, Depends

async def handle_request:
    dag = Pipeline() # 1 

    @dag.mark_node(timeout_in_ms=100, failsafe=2) # 2
    async def coro_a():
        await asyncio.sleep(0.5)
        print("FUNCTION {} after sleeping for {} s".format("coro_a", 0.5))

    @dag.mark_node(timeout_in_ms=100, failsafe=2)
    async def coro_b(x=Depends(coro_a)): # 3
        await asyncio.sleep(0.5)
        print("FUNCTION {} after sleeping for {} s".format("coro_c", 0.5))

    result = await dag.execute_graph_v2() # 4
    return result
```
Notes:
1. a pipeline == DAG, where node representing a unit of work, and directed edge representing the dependencies.
2. each unit of work is constrained to run under `timeout_in_ms`; if it does not, pipeline will pass `failsafe` value to downstream works.
3. the depedency is declared like FastAPI `Depends`. The caveat here is that the variable MUST BE part of pipeline FIRST.
4. `execute_graph_v2()` kick-starts and runs to completion.

# Why another workflow engine?

There are [DOZENS of workflow engine out there](https://github.com/meirwah/awesome-workflow-engines). `python-dirk` is **lightweight**:
- The entire package is under 300 lines, inclusive of comments and blank lines.
- It only depends on `loguru` and `networkx`. Plan to remove them in the future.
- Everything runs in an aysnc runtime loop.

Because it is lightweight, you can run it inside a REST endpoint.

# Why this engine over other engine?

You don't choose this over others. I have not run this in production, and neither should you.

# 