# Control run — #845 on unmodified `main`

- **Build**: `origin/main` `30faab7`, exported with `python3 .github/scripts/web_export.py --preset "Web Release"` and served locally; same browser, frame, DPR and driver as the parent run.
- **Result**: the same three taps selected and moved exactly as in the parent run. The screenshots were byte-identical after the taps, so they are not duplicated here; their SHA-256 values from that run are below.

```text
feb9d280c57c714639218f104f685ea9f1d21d56522e30428eb4cac2eef0d75b  board-00-before.png
fa9d14f1adc2dd681c952e5e2e1fb941a72904681781337fd871788bd44e3834  board-01-tap-219-654.png
b53c788f7f6cc501ca3deeb5fc77fb92078f0db4c0f4a4850130fc95b5d8ab8d  board-02-tap-painted-e2.png
1957c0fcc42afafda198d2cea7f03385850de1489c583ff46c696b60172f51d3  board-03-tap-painted-e4.png
1957c0fcc42afafda198d2cea7f03385850de1489c583ff46c696b60172f51d3  board-04-after.png
```

- **Reading**: [`readings.json`](readings.json) is that run's own output; it is identical to the parent `readings.json` apart from capture time.
