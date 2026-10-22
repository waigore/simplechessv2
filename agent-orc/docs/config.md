# agent-orc config

## Files

| Path | Role |
|------|------|
| [`.orc/config.yaml`](../../.orc/config.yaml) | Template defaults (do not edit in child projects) |
| `.orc/config.local.yaml` | Child-owned deep-merge override (gitignored) |
| [`.orc/config.local.example.yaml`](../../.orc/config.local.example.yaml) | Example local overrides |

Load order: `config.yaml`, then deep-merge `config.local.yaml` if present. Nested maps merge; leaves in local win. After merge, every string leaf is expanded for environment placeholders (see below).

## Environment substitution

Any string leaf in the merged config may use `${VAR}` or `${VAR:-default}` (no bare `$VAR`). Expansion runs once after deep-merge, before parsing.

- Unset `${VAR}` with no `:-` default → config load fails with `ConfigError` naming the variable.
- `${VAR:-default}` uses `default` when the variable is unset.
- Literals need no environment variables.
- Provider tokens `{prompt}`, `{workdir}`, `{skill}` are separate and still substituted at run time.

Primary use case: provider `--model` strings (and other argv/path/prompt values) from the environment via `.orc/config.local.yaml`. Keep secrets and machine-specific values in the environment or local config, not in template `config.yaml`. See [`.orc/config.local.example.yaml`](../../.orc/config.local.example.yaml).

## Orchestrator keys

- `cooldown_seconds` (default **10**): pause after a real agent run. `0` skips the pause.
- `gate_backoff_initial_seconds` (optional): first gate-miss delay. Later misses double it. When the merged config omits it, it equals the merged `cooldown_seconds`. `0` stays `0` on every miss, so the cap does not apply and the gate runs again immediately.
- `gate_backoff_max_seconds` (default **60**): cap for that doubling.
- `stagger_seconds` (default **5**): delay between skill loop starts.
- `worktrees_dir` / `logs_dir`: relative to repo root.
- `pull_before_run` / `default_branch`: `git pull` before each worktree.

## Providers

Named command templates with `{prompt}`, `{workdir}`, `{skill}`. The orchestrator also sets process `cwd` to the worktree.

Shipped defaults (see [`.orc/config.yaml`](../../.orc/config.yaml)):

| Provider | Binary | Headless + workdir |
|----------|--------|--------------------|
| cursor | `cursor-agent` (not bare `agent` — that may be Grok) | `-p --force --trust --workspace {workdir} {prompt}` |
| grok | `grok` | `-p {prompt} --cwd {workdir} --always-approve` |
| opencode | `opencode` | `run --auto {prompt}` (workdir via process cwd; no `--dir` on local v2.x) |
| opencode-qwen38-max | `opencode` | `run --auto --model opencode-go/qwen3.8-max {prompt}` ([OpenCode Go](https://opencode.ai/docs/go/)) |
| opencode-deepseek-v41-flash | `opencode` | `run --auto --model opencode-go/deepseek-v4.1-flash {prompt}` |

Default agent→provider: planner → `opencode-qwen38-max`; refine → `grok`; verify → `opencode-deepseek-v41-flash`; others → `cursor`.

## Agents

Each entry: `skill`, `provider`, `enabled`, `prompt`, optional `gate.command`, and optional timing. Each timing key falls back to the orchestrator value on its own:

| Key | Fallback |
|-----|----------|
| `cooldown_seconds` | `orchestrator.cooldown_seconds` |
| `gate_backoff_initial_seconds` | `orchestrator.gate_backoff_initial_seconds` |
| `gate_backoff_max_seconds` | `orchestrator.gate_backoff_max_seconds` |

Values are numbers `>= 0`. Setting one key does not change the others. The template omits `gate_backoff_initial_seconds` so a local `cooldown_seconds` override still moves the gate start with it. Set the initial key to keep them apart.

Shipped `project-planner-agent` sets `cooldown_seconds: 3600` (one hour after each run, success or failure). It has no gate, so gate backoff does not run. Other agents leave cooldown unset and use 10 seconds.

**Gate:** exit code **0** = pass (run agent); non-zero = miss. Omit `gate` → always pass. Stdout ignored.

Shipped workflow gates (open issues that include the status label):

```yaml
gate:
  command:
    - sh
    - -c
    - test "$(gh issue list --state open --label status:pending-review --limit 1 --json number)" != "[]"
```

`project-planner-agent` has no gate (always eligible).

`babysit-pr-agent` gates with [`.agents/skills/babysit-pr-agent/scripts/gate.sh`](../../.agents/skills/babysit-pr-agent/scripts/gate.sh) (exit 0 when a same-repo open PR is conflicted, behind its base, or has a failing check). Provider: `cursor`.

## Child projects

Only add/edit `.orc/config.local.yaml`. Keep template `config.yaml` intact for upstream sync.
