# Authoring rules: playtest traceability

Read this before editing `specs/playtest/traceability.md`. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md).

How playtesting aligns with the vision, definition, quality, design, and UX. View is out of playtest scope; do not map view stories as playtest targets.

## Alignment

Every playtest global and protocol serves a vision quality, a definition scope item, a design spec, or a UX spec. Nothing serves only a non-goal or an out-of-scope item.

Each row names the upstream item, its source (`vision`, `definition`, `design`, or `ux`), and links to the playtest specs that serve it. Map tools, procedures, evidence, coverage, and every protocol file.

## Topic coverage

Each topic in the table is covered, or marked N/A. Fill Applicability with "Applies" or "N/A — reason". The reason is grounded in the definition, design, or UX. Do not delete a topic row to skip it.

## Splitting

If the file passes 500 words, move the alignment table to `traceability/alignment.md`. Leave a summary and a link, and update `playtest.md`.

A story-to-protocol map may sit alongside it as a `traceability/story-protocol/` set: the index `traceability/story-protocol.md` plus per-view files under `traceability/story-protocol/`. Each file in the set states the judging rule only by citing the playtest spec that owns it; the set defines no rule of its own. Keep every file in the set under 500 words and link the index from `playtest.md`.
