# Notes — #62 localization verify-fix remediations

- Headless Godot 4.7.2; `GODOT_BIN` → cached macOS universal binary.
- `AssetResolver` now chains every Font face of a multi-file catalog asset (TC then JP for `fonts/noto-sans-cjk`).
- `string_table_test` resolves Latin+CJK, asserts JP fallback present, and checks every shipped Copy glyph against the chain (including UIS.T3 clock digits).
- Layout: mode-pick S1/S3/S4, shared-setup, shared-play S1/S2/S4/S5/S6, and shared-result at 720×1280 for `en` / `zh-Hant` / `ja`, each with ~40% length growth and no clipped chrome; board `offset_top` stays under play chrome.
- Graphical PNG spot-check deferred to `../graphical-20261021T225828Z/` (dummy renderer cannot `texture_2d_get` in `--headless`).
