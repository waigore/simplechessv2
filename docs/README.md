# `docs/`

Project and process documentation (labels, issues, skills, repo setup). Product/technical specifications live in [`specs/`](../specs/).

## Concise docs

Every file under `docs/` must stay under **500 words**. If content would exceed that, split into multiple focused files and link between them. CI enforces this for Markdown (`word-limit` in [Spec lint](spec-lint.md)); run `python3 .github/scripts/spec_lint.py` locally.

## Index

| Path | Covers |
|------|--------|
| [asset-tools.md](asset-tools.md) | Asset tools index: bans, preference; Recraft, ElevenLabs, fal linked |
| [mcp.md](mcp.md) | Project MCP wiring for Cursor / OpenCode / Grok; auth rules; declared servers; smoke test |
| [coding-conventions.md](coding-conventions.md) | Project-owned coding conventions and lint/format/unit-test/coverage tooling; extends `solid.md` |
| [demos.md](demos.md) | Gameplay demos under `demos/`: scope, what is relaxed, traceability, promotion |
| [demo-style-assets.md](demo-style-assets.md) | Demos as style and asset-pipeline proofs of concept: gate, assets, findings, verification |
| [dev-env-setup.md](dev-env-setup.md) | Local game-stack and asset-tool install/verify; then `setup-unit-test-ci` |
| [open-design-skill-setup.md](open-design-skill-setup.md) | User-local Open Design skill + content under `~/.open-design-skill/`; optional agent wiring |
| [github-repo-setup.md](github-repo-setup.md) | First-time GitHub settings to apply and verify (Actions, `main` ruleset, squash, auto-merge, labels) |
| [github-repo-setup-examples.md](github-repo-setup-examples.md) | Non-binding example commands for the setup |
| [issues/](issues/) | Epic / Task / Defect contract and status workflow |
| [labels.md](labels.md) | Label catalog and sync |
| [pull-requests.md](pull-requests.md) | PR flow, branch names, body contract, auto-merge holds |
| [requirements/](requirements/README.md) | Unconfirmed requirement notes awaiting capture into specs (not specs) |
| [playtest/evidence/](playtest/evidence/) | AI-agent playtest evidence (story IDs, pass/fail, screenshots, notes, logs); requirements in `specs/playtest/` |
| [skills.md](skills.md) | Skill authoring and native wiring |
| [solid.md](solid.md) | SOLID principles + structure continuity for agents; owned by the template |
| [spec-lint.md](spec-lint.md) | CI checks for spec structure (rules line, templates, links, glossaries) |
