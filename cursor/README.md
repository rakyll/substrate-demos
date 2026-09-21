# Cursor

Run Cursor Agent tools (`read_file`, `write_file`, `shell`) inside an isolated Agent Substrate environment via the [`ate-env`](https://github.com/agent-substrate/env) MCP server.

1. **Create an environment and forward the API:**

   ```bash
   kubectl port-forward -n ate-env svc/ate-env-api 7777:7777
   ate-env create my-sandbox
   ```

2. **Add the Substrate MCP server to Cursor:**

   Add the server to `.cursor/mcp.json` in your project root:

   ```json
   {
     "mcpServers": {
       "substrate": {
         "url": "http://127.0.0.1:7777/v1alpha/envs/my-sandbox/mcp"
       }
     }
   }
   ```

3. **Use Cursor Agent:**

   Open Cursor Composer (`Cmd+I`) or Chat (`Cmd+L`). The agent will route command execution and file operations through the Substrate sandbox.

4. **Suspend or delete when done:**

   ```bash
   ate-env suspend my-sandbox
   ate-env delete my-sandbox
   ```
