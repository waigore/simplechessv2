# Finding — the `ambient` group's resolution depends on the build machine (defect #812)

Repeating both builds from clean trees showed why the pre-patch export could not reproduce the shipped defect: the runtime copy is present in the built pack only when `audio_runtime/*.ogg` has been imported into the (git-ignored) `.godot` cache, and the export imports whatever is on disk when it runs.

- A tree that has imported once loads its `ambient` group **with or without** the fix.
- A tree that has never imported it does not have the route at all (`FileAccess.get_file_as_bytes` → 0 B, `load_from_buffer` decodes nothing).

That is not a reason to withhold acceptance: on the artifact #799 ships, the group resolves through the route the spec names, and the code change is the one that reads that route. It is a reason to file a defect, because the release path still has no reading that tells a good bundle from a broken one, and the resolver's success now depends on what a developer's machine happened to import.

Filed as **#812** — a `Web Release` export whose builder never imported `audio_runtime` ships a silent ambient group, and no guard reads it.
