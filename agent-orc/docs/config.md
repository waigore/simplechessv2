# agent-orc config

## Files

| Path | Role |
|------|------|
| [`.orc/config.yaml`](../../.orc/config.yaml) | Template defaults (do not edit in child projects) |
| `.orc/config.local.yaml` | Child-owned deep-merge override (gitignored) |
| [`.orc/config.local.example.yaml`](../../.orc/config.local.example.yaml) | Example local overrides |

Load order: `config.yaml`, then deep-merge `config.local.yaml` if present. Nested maps merge; leaves in local win.

## Orchestrator keys

- `cooldown_seconds` (default **10**): wait after a real agent run; also initial gate-miss backoff.
- `gate_backoff_max_seconds` (default **60**): cap for consecutive gate misses (doubling).
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

Each entry: `skill`, `provider`, `enabled`, `prompt`, optional `gate.command`.

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

## Child projects

Only add/edit `.orc/config.local.yaml`. Keep template `config.yaml` intact for upstream sync.
