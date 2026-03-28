---
name: model-route
description: Automatic model selection based on task complexity
triggers: ["model route", "select model", "which model", "route model"]
---

# Model Route

Recommend the optimal model for the current task.

## When to Use
- Before starting a new task
- When unsure about cost vs capability tradeoff
- When session costs are high

## Decision Matrix

### Haiku (Lowest Cost)
- Simple file lookups and exploration
- Typo corrections and formatting
- Code explanation and documentation reading
- Subagent delegation tasks
- Repetitive pattern application

### Sonnet (Balanced)
- Feature implementation
- Code review and testing
- Bug fixing and debugging
- Database queries and schema work
- Standard refactoring

### Opus (Highest Capability)
- Complex architectural decisions
- Multi-file refactoring with cross-cutting concerns
- Security vulnerability analysis
- Novel algorithm design
- Ambiguous requirements interpretation

## How It Works

1. Analyze the user's current task description
2. Classify complexity (low/medium/high)
3. Consider context: file count, dependency depth, risk level
4. Recommend model with reasoning
5. Suggest `/model [name]` command if switch needed

## Cost Estimates

| Model | Input (1M tokens) | Output (1M tokens) |
|-------|-------------------|---------------------|
| Haiku | $0.80 | $4.00 |
| Sonnet | $3.00 | $15.00 |
| Opus | $15.00 | $75.00 |
