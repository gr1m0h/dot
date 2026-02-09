---
name: protocol-check
description: Analyze communication protocol implementation for correctness and security
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: protocol-analyzer
argument-hint: "<protocol-implementation-file-or-module>"
---

Analyze the protocol implementation for correctness and security.

## Context

Protocol-related files:
!`find . -name "*protocol*" -o -name "*mqtt*" -o -name "*coap*" -o -name "*modbus*" -o -name "*ble*" -o -name "*can*" 2>/dev/null | head -15`

## Target: $ARGUMENTS

## Instructions

1. Identify the protocol being implemented
2. Map the state machine (states, transitions, events)
3. Check for missing error states and timeout handling
4. Verify security measures (encryption, authentication, replay protection)
5. Assess standards compliance
6. Generate protocol analysis report
