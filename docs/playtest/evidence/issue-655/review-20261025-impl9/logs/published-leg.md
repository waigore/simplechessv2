# Published leg — criterion 6 on `ce8a156`

Artefact: `https://waigore.github.io/simplechessv2/index.pck` — `last-modified`
2026-10-24 13:00:58 GMT, `9561236` bytes, `etag "6adcac0a-91e494"`, from CI run
40096272525 on `a5b35ae` (see `build-identity.txt` in this folder).

Byte-identical to the artefact `../review-20261025-impl7` measured in a browser, so
criterion 6's published rows cannot differ from the ones logged there.

Sequencing-note condition, checked live:

- `#648` — `status:pending-implementation`; `gh pr list --state all --search "648 in:title"`
  → none; its `specs/` sentence absent (see `criterion1-grep.log`).
- `#479` — `status:pending-acceptance`; PR #806 **open** (`BEHIND`, 8 checks green,
  auto-merge on), so ADR-0010's delivery text is not on `main`.
- Release runs after 40096272525: 40096532811 and 40096643098, both **failed** — nothing
  newer was published.

Verdict: **held** under *Expected behavior*'s sequencing note.
