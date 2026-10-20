"""Load and deep-merge .orc/config.yaml + config.local.yaml."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


class ConfigError(Exception):
    """Invalid or incomplete orchestrator configuration."""


def deep_merge(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    """Recursively merge override into base; override wins on leaf conflicts."""
    result = dict(base)
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = value
    return result


@dataclass
class GateConfig:
    command: list[str]


@dataclass
class AgentConfig:
    name: str
    skill: str
    provider: str
    enabled: bool
    prompt: str
    gate: GateConfig | None = None


@dataclass
class OrchestratorConfig:
    cooldown_seconds: float = 10.0
    gate_backoff_max_seconds: float = 60.0
    stagger_seconds: float = 5.0
    worktrees_dir: str = ".orc/worktrees"
    logs_dir: str = ".orc/logs"
    repo_root: str = "."
    pull_before_run: bool = True
    default_branch: str = "main"


@dataclass
class AppConfig:
    orchestrator: OrchestratorConfig
    providers: dict[str, list[str]]
    agents: dict[str, AgentConfig]
    config_dir: Path = field(default_factory=lambda: Path(".orc"))


def _as_command(value: Any, label: str) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, list) and all(isinstance(x, (str, int, float)) for x in value):
        return [str(x) for x in value]
    raise ConfigError(f"{label} must be a string or list of strings")


def _parse_orchestrator(raw: dict[str, Any]) -> OrchestratorConfig:
    return OrchestratorConfig(
        cooldown_seconds=float(raw.get("cooldown_seconds", 10)),
        gate_backoff_max_seconds=float(raw.get("gate_backoff_max_seconds", 60)),
        stagger_seconds=float(raw.get("stagger_seconds", 5)),
        worktrees_dir=str(raw.get("worktrees_dir", ".orc/worktrees")),
        logs_dir=str(raw.get("logs_dir", ".orc/logs")),
        repo_root=str(raw.get("repo_root", ".")),
        pull_before_run=bool(raw.get("pull_before_run", True)),
        default_branch=str(raw.get("default_branch", "main")),
    )


def _parse_providers(raw: dict[str, Any]) -> dict[str, list[str]]:
    providers: dict[str, list[str]] = {}
    for name, body in raw.items():
        if not isinstance(body, dict) or "command" not in body:
            raise ConfigError(f"providers.{name} must have a command")
        providers[name] = _as_command(body["command"], f"providers.{name}.command")
    return providers


def _parse_agents(
    raw: dict[str, Any], providers: dict[str, list[str]]
) -> dict[str, AgentConfig]:
    agents: dict[str, AgentConfig] = {}
    for name, body in raw.items():
        if not isinstance(body, dict):
            raise ConfigError(f"agents.{name} must be a mapping")
        provider = str(body.get("provider", ""))
        if provider not in providers:
            raise ConfigError(
                f"agents.{name}.provider '{provider}' is not defined under providers"
            )
        gate = None
        gate_raw = body.get("gate")
        if gate_raw is not None:
            if not isinstance(gate_raw, dict) or "command" not in gate_raw:
                raise ConfigError(f"agents.{name}.gate must have a command")
            gate = GateConfig(
                command=_as_command(gate_raw["command"], f"agents.{name}.gate.command")
            )
        agents[name] = AgentConfig(
            name=name,
            skill=str(body.get("skill", name)),
            provider=provider,
            enabled=bool(body.get("enabled", True)),
            prompt=str(body.get("prompt", "")).strip(),
            gate=gate,
        )
        if not agents[name].prompt:
            raise ConfigError(f"agents.{name}.prompt is required")
    return agents


def load_config(config_dir: Path | None = None) -> AppConfig:
    """Load config.yaml and optional config.local.yaml from config_dir."""
    root = Path(config_dir) if config_dir is not None else Path(".orc")
    base_path = root / "config.yaml"
    if not base_path.is_file():
        raise ConfigError(f"Missing config file: {base_path}")

    with base_path.open(encoding="utf-8") as fh:
        base = yaml.safe_load(fh) or {}
    if not isinstance(base, dict):
        raise ConfigError("config.yaml must be a mapping")

    local_path = root / "config.local.yaml"
    if local_path.is_file():
        with local_path.open(encoding="utf-8") as fh:
            local = yaml.safe_load(fh) or {}
        if not isinstance(local, dict):
            raise ConfigError("config.local.yaml must be a mapping")
        merged = deep_merge(base, local)
    else:
        merged = base

    orch_raw = merged.get("orchestrator") or {}
    if not isinstance(orch_raw, dict):
        raise ConfigError("orchestrator must be a mapping")
    providers_raw = merged.get("providers") or {}
    if not isinstance(providers_raw, dict):
        raise ConfigError("providers must be a mapping")
    agents_raw = merged.get("agents") or {}
    if not isinstance(agents_raw, dict):
        raise ConfigError("agents must be a mapping")

    providers = _parse_providers(providers_raw)
    agents = _parse_agents(agents_raw, providers)
    return AppConfig(
        orchestrator=_parse_orchestrator(orch_raw),
        providers=providers,
        agents=agents,
        config_dir=root.resolve(),
    )


def enabled_agents(config: AppConfig) -> list[AgentConfig]:
    return [a for a in config.agents.values() if a.enabled]
