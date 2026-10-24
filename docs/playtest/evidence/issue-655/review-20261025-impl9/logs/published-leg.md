# Published leg — criterion 6 on `ce8a156`

Artefact: `https://waigore.github.io/simplechessv2/index.pck` — `last-modified`
2026-10-24 13:00:58 GMT, `9561236` bytes, `etag "6adcac0a-91e494"`, from CI run
40096272525 on `a5b35ae` (see `build-identity.txt` in this folder).

Byte-identical to the artefact `../review-20261025-impl7` measured in a browser, so
criterion 6's published rows cannot differ from the ones logged there.

Sequencing-note condition, checked live:

- `#648` — **landed mid-pass**: PR #815 merged as `a94210d` after this pass's
  measurement (see `landed-648.md`). Its sentence is now on `main`.
- `#479` — `status:pending-acceptance`; PR #806 **open** (`BEHIND`, 8 checks green,
  auto-merge on), so ADR-0010's delivery text is not on `main`.
- Release runs after 40096272525: 40096532811 and 40096643098, both **failed** — nothing
  newer was published.

Verdict: **held** under *Expected behavior*'s sequencing note — only the #479 half of
its condition remains, and the published artefact still predates `a94210d`.
