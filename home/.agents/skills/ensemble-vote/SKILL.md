---
name: ensemble-vote
description: Execute ensemble voting with multiple reasoning paths for important decisions. Use when user says "ensemble vote", "multi-perspective analysis", "get multiple opinions", or facing high-risk architectural or design choices.
user-invocable: true
allowed-tools: Read, Grep, Glob
context: fork
agent: ensemble-reasoner
---

# Ensemble Voting

Executes a Self-Consistency Ensemble vote for the decision on $ARGUMENTS.

## Process

1. Launch the ensemble-reasoner agent
2. Generate 5 different reasoning paths
3. Tally voting results
4. Report the final judgment with confidence score

## Usage Examples

```
> /ensemble-vote Is this authentication system design secure?
> /ensemble-vote What is the optimal database indexing strategy?
> /ensemble-vote Is this refactoring worthwhile?
```
