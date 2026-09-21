# Agent Substrate Demos

A collection of demos showcasing Agent Substrate.

## Demos

### [Environment](env/)

The `demo.bash` script in the [env/](env/) directory walks through the lifecycle of an Agent Substrate Environment using the `ate-env` CLI. It provisions an isolated sandbox, runs commands and batch tasks inside the guest, reads and writes files, suspends the environment to a snapshot, verifies persisted state upon resuming, and tears down the environment.

### [Antigravity](antigravity/)

The [antigravity/](antigravity/) guide shows how to connect the Antigravity CLI (`agy`) to Agent Substrate via `agy mcp add`, routing tool executions into an isolated sandbox environment.

### [Claude](claude/)

The [claude/](claude/) guide shows how to connect Claude Code to Agent Substrate via `claude mcp add`, routing Claude Code's file operations and shell execution into an isolated, stateful sandbox environment instead of the local host.



