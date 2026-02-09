---
name: firmware-audit
description: Audit firmware code for security vulnerabilities and embedded best practices
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: edge-security
argument-hint: "[target-directory]"
---

Perform a security audit on firmware/embedded code.

## Context

Source files:
!`find . -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.rs" 2>/dev/null | head -20`

Build system:
!`ls Makefile CMakeLists.txt build.rs Cargo.toml platformio.ini 2>/dev/null`

## Target: $ARGUMENTS

## Instructions

1. Scan for hardcoded credentials (passwords, keys, tokens)
2. Check for buffer overflow risks (unbounded copies, format strings)
3. Verify secure boot and update mechanisms
4. Audit communication protocols for encryption and authentication
5. Check physical interface security (debug ports, JTAG)
6. Generate structured security audit report
