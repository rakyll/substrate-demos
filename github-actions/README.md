# GitHub Actions

Run automated CI jobs and untrusted pull request workloads inside isolated Agent Substrate sandboxes using [`ate-env`](https://github.com/agent-substrate/env).

1. **Create an environment for the pull request:**

   ```bash
   ate-env create pr-42
   ```

2. **Clone and test inside the isolated sandbox:**

   ```bash
   ate-env pr-42 shell "git clone https://github.com/org/repo.git /workspace && cd /workspace && make test"
   ```

3. **Extract artifacts and test reports:**

   ```bash
   ate-env pr-42 read /workspace/report.json
   ```

4. **Delete the environment on completion:**

   ```bash
   ate-env delete pr-42
   ```

---

## GitHub Actions Example

```yaml
name: Sandboxed PR Check
on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Create Substrate Sandbox
        run: ate-env create "pr-${{ github.event.number }}"

      - name: Run Tests in Sandbox
        run: |
          ate-env "pr-${{ github.event.number }}" shell \
            "git clone ${{ github.event.repository.clone_url }} /workspace && cd /workspace && make test"

      - name: Extract Test Report
        run: ate-env "pr-${{ github.event.number }}" read /workspace/report.json > report.json

      - name: Cleanup Sandbox
        if: always()
        run: ate-env delete "pr-${{ github.event.number }}"
```
