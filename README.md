# Agent Substrate Demos

A collection of demos showcasing Agent Substrate.

## Demos

### [Environment](env/)

The `demo.bash` script in the [env/](env/) directory walks through the lifecycle of an Agent Substrate Environment using the `ate-env` CLI. It provisions an isolated sandbox, runs commands and batch tasks inside the guest, reads and writes files, suspends the environment to a snapshot, verifies persisted state upon resuming, and tears down the environment.
