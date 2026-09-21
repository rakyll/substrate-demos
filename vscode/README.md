# VS Code

Connect desktop VS Code into an isolated Agent Substrate development environment via Remote Tunnels using [`ate-env`](https://github.com/agent-substrate/env).

1. **Create an environment:**

   ```bash
   ate-env create dev-box
   ```

2. **Launch the VS Code tunnel inside the sandbox:**

   ```bash
   ate-env dev-box shell "curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' | tar -xz && ./code tunnel --accept-server-license-terms --name dev-box"
   ```

3. **Connect from VS Code:**

   Open VS Code and run **Remote-Tunnels: Connect to Tunnel...** from the Command Palette (`Cmd+Shift+P`), then select `dev-box`.

4. **Suspend or resume when done:**

   ```bash
   ate-env suspend dev-box
   ate-env resume dev-box
   ```
