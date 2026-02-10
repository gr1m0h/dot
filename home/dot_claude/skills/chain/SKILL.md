---
name: chain
description: Build chains that execute multiple skills sequentially
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# Skill Chaining

Builds and executes chains that run multiple skills sequentially.

## Syntax

```
/chain skill1 -> skill2 -> skill3
```

## Predefined Chains

Predefined chains use Task subagent types (launched via Task tool). Custom chains can mix Skills and agents.

### feature (new feature development)

```
task-planner -> coder -> test-writer -> code-reviewer
```

### bugfix (bug fix)

```
debugger -> coder -> test-writer -> code-reviewer
```

### refactor (refactoring)

```
code-reviewer -> coder -> test-writer -> code-reviewer
```

### security-review (security review)

```
security-auditor -> code-reviewer -> coder (fix) -> security-auditor (verify)
```

## Chain Execution Rules

### 1. Sequential Execution

Each skill waits for the previous skill to complete

### 2. Context Propagation

The output of the previous skill becomes the input for the next skill

### 3. Abort on Failure

If a skill fails, the chain is aborted

- /chain --continue to force continuation

### 4. Checkpoints

Automatically creates a checkpoint when each skill completes

## Custom Chain Definition

`.claude/chains/custom-chain.yaml`:

```yaml
name: my-custom-chain
description: Custom chain description
steps:
    - skill: task-planner
      output_key: plan
    - skill: coder
      input_from: plan
      output_key: code
    - skill: test-writer
      input_from: code
      condition: "code.files_changed > 0"
```

## Usage Examples

```
# Predefined chain
> /chain feature Add a new login feature

# Custom chain
> /chain debugger -> coder -> reflect

# Conditional execution
> /chain coder -> test-writer --if-changed
```
