---
name: tot
description: Find the optimal solution using Tree of Thoughts exploration
user-invocable: true
allowed-tools: Read, Grep, Glob
context: fork
agent: tot-planner
---

# Tree of Thoughts Problem Solving

Executes a Tree of Thoughts exploration for the problem in $ARGUMENTS.

## Process

1. Launch the tot-planner agent
2. Decompose the problem and build a tree
3. Evaluate each path
4. Select the optimal path and report

## Usage Examples

```
> /tot How to improve the authentication flow
> /tot Best approach to fix this bug
> /tot Database schema design
```
