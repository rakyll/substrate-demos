#!/usr/bin/env bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

# ---------------------------------------------------------------------------
# Formatting (disabled when stdout is not a terminal or NO_COLOR is set)
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\033[1m'  DIM=$'\033[2m'    RESET=$'\033[0m'
  CYAN=$'\033[36m' GREEN=$'\033[32m' YELLOW=$'\033[33m'
  BLUE=$'\033[34m' RED=$'\033[31m'
else
  BOLD="" DIM="" RESET="" CYAN="" GREEN="" YELLOW="" BLUE="" RED=""
fi

API_PORT="${API_PORT:-7777}"
API_ADDR="127.0.0.1:${API_PORT}"
ENV_ID="demo-$(date +%s)"
PF_PID=""
TOTAL_STEPS=7
STEP_NO=0
STEP_LABELS=()
STEP_TIMES=()

cleanup() {
  if [ -n "$PF_PID" ]; then
    kill "$PF_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
now() {
  if [[ "$OSTYPE" == darwin* ]]; then
    python3 -c 'import time; print(time.time())'
  else
    date +%s.%N
  fi
}

elapsed() {
  awk -v s="$1" -v e="$2" 'BEGIN { printf "%.2f", e - s }'
}

# Print a line to stdout with an indented gutter for guest/CLI output.
gutter() {
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    printf '  %s│%s %s\n' "$DIM" "$RESET" "$line"
  done
}

step() {
  STEP_NO=$((STEP_NO + 1))
  printf '\n%s%s[%d/%d]%s %s%s%s\n' \
    "$BOLD" "$CYAN" "$STEP_NO" "$TOTAL_STEPS" "$RESET" "$BOLD" "$1" "$RESET"
}

note() {
  printf '  %s%s%s\n' "$DIM" "$1" "$RESET"
}

# run LABEL CMD [ARGS...]
# Shows the command, streams its output through the gutter, and records timing.
# Set SHOW_CMD to override the displayed command (e.g. for piped commands).
run() {
  local label="$1"; shift
  local display="${SHOW_CMD:-$*}"
  local start end secs
  printf '  %s$ %s%s\n' "$DIM" "$display" "$RESET"
  start=$(now)
  if ! { "$@" 2>&1 | gutter; }; then
    printf '  %s✘ %s failed%s\n' "$RED" "$label" "$RESET"
    exit 1
  fi
  end=$(now)
  secs=$(elapsed "$start" "$end")
  printf '  %s✔%s %s %s(%ss)%s\n' "$GREEN" "$RESET" "$label" "$DIM" "$secs" "$RESET"
  STEP_LABELS+=("$label")
  STEP_TIMES+=("$secs")
}

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------
printf '\n%s%s  Agent Substrate Environment%s\n' "$BOLD" "$BLUE" "$RESET"

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
if ! command -v ate-env &>/dev/null; then
  printf '  %s⚠ ate-env not found. Install from https://github.com/agent-substrate/env%s\n' "$YELLOW" "$RESET"
  go install github.com/agent-substrate/env/cmd/ate-env@latest
fi

if ! curl -s --max-time 1 "http://${API_ADDR}/healthz" &>/dev/null; then
  note "Starting port-forward to ate-env-api on :${API_PORT}"
  kubectl port-forward -n ate-env svc/ate-env-api "${API_PORT}:${API_PORT}" &>/dev/null &
  PF_PID=$!
  sleep 1.5
fi

export SUBSTRATE_ENV_API="${API_ADDR}"
KUBE_CTX="$(kubectl config current-context 2>/dev/null || echo 'unknown')"
printf '  %-13s%s%s%s\n' "Context" "$BOLD" "$KUBE_CTX" "$RESET"
printf '  %-13s%s%s%s\n' "Environment" "$BOLD" "$ENV_ID" "$RESET"

DEMO_START=$(now)

# ---------------------------------------------------------------------------
# Steps
# ---------------------------------------------------------------------------
step "Create an isolated environment"
run "Environment created" ate-env create "${ENV_ID}"

step "Run a command inside the guest"
run "Command executed" \
  ate-env "${ENV_ID}" shell 'echo "Host: $(hostname) | Kernel: $(uname -s -r -m) | Uptime: $(uptime -p 2>/dev/null || uptime)"'

step "Write and read a file"
SAMPLE_DATA="Agent Substrate Environment
Timestamp: $(date)
Target: ${ENV_ID}
State: Active"

SHOW_CMD="echo \"\$SAMPLE_DATA\" | ate-env ${ENV_ID} write /workspace/data.txt" \
run "File written" \
  bash -c "echo \"$SAMPLE_DATA\" | ate-env '${ENV_ID}' write /workspace/data.txt"

run "File read back" \
  ate-env "${ENV_ID}" read /workspace/data.txt

step "Run a multi-line task"
TASK_CMD='echo "Task: batch data processing" && for i in 1 2 3 4 5; do echo "  - Processing item $i/5"; done'
run "Task executed" \
  ate-env "${ENV_ID}" shell "${TASK_CMD}"

step "Suspend the environment (snapshot)"
run "Environment suspended" ate-env suspend "${ENV_ID}"

step "Resume on demand and verify persisted state"
run "State restored from snapshot" \
  ate-env "${ENV_ID}" shell 'cat /workspace/data.txt'

step "Delete the environment"
run "Environment deleted" ate-env delete "${ENV_ID}"

DEMO_END=$(now)

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
printf '\n%sSummary%s\n' "$BOLD" "$RESET"
printf '  %s────────────────────────────────────────────%s\n' "$DIM" "$RESET"
for i in "${!STEP_LABELS[@]}"; do
  printf '  %-36s %6ss\n' "${STEP_LABELS[$i]}" "${STEP_TIMES[$i]}"
done
printf '  %s────────────────────────────────────────────%s\n' "$DIM" "$RESET"
printf '  %s%-36s %6ss%s\n' "$BOLD" "Total" "$(elapsed "$DEMO_START" "$DEMO_END")" "$RESET"

printf '\n%s%s✨ Demo completed successfully%s\n\n' "$BOLD" "$GREEN" "$RESET"
