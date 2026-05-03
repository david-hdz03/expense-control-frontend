---
name: Codebase lint baseline
description: The existing codebase uses Dart 2 Key? constructor style and withOpacity; treat info-level lints as pre-existing
type: feedback
---

All existing files use `Key? key` constructor parameter pattern and `Color.withOpacity()` throughout.

**Why:** The project was scaffolded with Dart 2 patterns and has not been migrated to super parameters or `.withValues()`. These are flagged as `info`-level by flutter_lints but are not regressions.

**How to apply:** When running `flutter analyze`, only treat `warning` and `error` level issues as blockers. The 100+ `info`-level deprecation notices about `withOpacity` and `use_super_parameters` are pre-existing baseline noise — do not report them as new issues or spend time fixing them unless the user explicitly asks.
