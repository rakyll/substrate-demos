# Antigravity

Run Antigravity CLI (`agy`) tools (`read_file`, `write_file`, `shell`) inside an isolated Agent Substrate environment via MCP.

1. **Create an environment and forward the API:**

   ```bash
   kubectl port-forward -n ate-env svc/ate-env-api 7777:7777
   ate-env create my-sandbox
   ```

2. **Add the Substrate MCP server to Antigravity:**

   ```bash
   agy mcp add substrate http://127.0.0.1:7777/v1alpha/envs/my-sandbox/mcp
   ```

3. **Run Antigravity CLI:**

   ```bash
   agy
   ```

4. **Suspend or delete when done:**

   ```bash
   ate-env suspend my-sandbox
   ate-env delete my-sandbox
   ```
