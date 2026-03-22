# Task Plan Overview

Task breakdown based on docs/SPEC.md Section 4 (Improvement Policies).
Listed in execution order considering dependencies.

## Dependency Summary

```
Phase 1 (Foundation)
  1.1 Split home.nix ──────────┐
  1.2 Clean up shell-hook ────┤
                               v
Phase 2 (Cross-platform)
  2.1 Multi-system support ────┤ (depends on 1.1)
  2.2 Environment overrides ───┤ (depends on 1.1, 2.1)
  2.3 Unfree cleanup ──────────┘ (depends on 2.1, 2.2)
                               v
Phase 3 (Named Profiles)       (depends on Phase 2)
  3.1 Rename overrides/ to platforms/ ─┐
  3.2 profileDefs + homeConfigurations  ├─ implement together
  3.3 profiles/ directory ──────────────┘
                               v
Phase 4 (zinit Integration)    (depends on Phase 1)
  4.1 zinit module ────────────── (depends on shell-hook module)
                               v
Phase 5 (Neovim Config Migration)  (independent; deployable any time after Phase 1)
  5.1 rc.vim → Lua migration ──── (no phase dependencies)
                               v
Phase 6 (Backlog)
  6.1 Extract modules to separate repo ── (depends on 4.1 stable)
```

## Common Constraints

The following must be observed across all tasks:

- **Do not use `programs.*`** (only exception: `programs.home-manager.enable`)
- **Do not manage login shells**
- **Do not delete unconfigured packages/code**
- **Keep the shell-hook module simple** (load-order control only)
- Verify existing behavior with `home-manager build` after completing each task

Current progress: Phases 1-3 complete, Phase 4 next.

Last updated: 2026-03-22
