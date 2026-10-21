# agent-orc architecture

## Layers

1. **CLI** (`cli.py`): argparse, config load, multi-select, asyncio entry.
2. **Supervisor** (`supervisor.py`): one asyncio task per selected skill; stagger, gate, pull, worktree, run, cooldown.
3. **Gate** (`gate.py`): optional subprocess; exit 0 to proceed.
4. **Worktree** (`worktree.py`): create/delete isolated checkouts; pull on orchestrator root.
5. **Crew bridge** (`crew/`): CrewAI Agent/Task/Crew + `ProviderCliTool`; default path invokes the tool directly (no LLM) so CLI cost is the agent run itself. Optional `use_crew_kickoff` for future LLM-driven use.
6. **Providers** (`providers/`): render configured argv templates.
7. **Messaging** (`messaging.py`): no-op `publish` / `subscribe` for later agent-to-agent hooks.
8. **Shutdown** (`shutdown.py`): SIGINT confirm, kill process groups, purge worktrees.
9. **github_gh** (`github_gh.py`): thin `gh` wrapper for e2e (not used by the daemon loop).

## Parallelism

Skills run concurrently. Within a skill: at most one agent process. Gate misses never start a worktree or CLI. Post-run cooldown and gate-miss backoff resolve on the agent, then the orchestrator defaults.

## Extensibility

- New provider: add template under `providers:` in config (and optional module stub).
- New skill agent: add under `agents:` with prompt and optional gate.
- Future bus: replace no-ops in `messaging.py`; supervisor already publishes `skill.start` / `skill.end`.
