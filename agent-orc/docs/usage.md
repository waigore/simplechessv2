# agent-orc usage

## Install

```bash
cd agent-orc
uv sync --group dev
```

Requires `git` and (for shipped gates / e2e) `gh`. Provider CLIs (cursor / grok / opencode) must be on `PATH` when not using a local override.

## Run

From the **repository root** (so `.orc/` resolves):

```bash
cd agent-orc && uv run agent-orc                 # daemon
uv run agent-orc --yes                           # all enabled; no multi-select
uv run agent-orc -n 3 --yes                      # each skill × 3, then exit
uv run agent-orc --agents issue-workflow-review-agent -n 1
```

Startup multi-select (TTY, no `--yes`/`--agents`) defaults to every enabled agent checked.

## Lifecycle

Per skill (in parallel, staggered by 5s): gate → pull → worktree → agent CLI → delete worktree → cooldown (10s) → repeat. Gate misses use backoff 10→20→40→60s and do not count toward `-n`.

## Shutdown

Ctrl-C with running agents: warn and confirm (TTY). Confirm or second Ctrl-C / non-TTY: kill agent process groups and purge worktrees. Exit code **130**.

Startup/config errors: exit **2**. Otherwise **0**, or **1** if a skill loop raised.

## Logs

Under `.orc/logs/`: `orchestrator.log` and `.orc/logs/<agent>/run-<timestamp>.log`.

## Tests

```bash
uv run pytest -m "not e2e"
uv run pytest -m "not e2e" && uv run pytest -m e2e
```

E2e creates a `[orc-e2e]` GitHub issue and expects `status:accepted`. Needs `gh` auth and real provider CLIs.

## Manual smoke

1. Copy `.orc/config.local.example.yaml` → `.orc/config.local.yaml`; point one agent at a real CLI.
2. `uv run agent-orc -n 1 --agents issue-workflow-review-agent`
3. Confirm worktree under `.orc/worktrees/` during the run, gone after.
4. Ctrl-C mid-run → confirm → processes and worktrees cleared.
