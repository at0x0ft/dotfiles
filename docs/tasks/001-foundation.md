# Phase 1: Foundation (Prerequisites for Other Tasks)

## 1.1 Split home.nix (Policy 4.3)

**Goal**: Minimize home.nix responsibilities, creating the foundation for environment-specific overrides (4.2) and multi-shell support (4.4).

- [x] Create `home-manager/base.nix`
  Done when: `home.packages`, `shell.hook.entries`, and `.zshrc` generation are in base.nix
- [x] Reduce home.nix to minimal composition
  Done when: home.nix only contains user identity, imports, and `programs.home-manager.enable`
- [x] Verify no-diff build with `home-manager build --flake .#at0x0ft`
  Done when: build succeeds with identical output

**Changed files**: `home.nix` (edit), `home-manager/base.nix` (new)

---

## 1.2 Clean Up shell-hook Module (Policy 4.5)

**Goal**: Resolve the TODO comment and improve `baseDir` option consistency.

- [x] Clarify `baseDir` option usage as the `xdg.configFile` target path
  Done when: baseDir semantics are documented or self-evident
- [x] Resolve the TODO comment (refactor or remove)
  Done when: no TODO comments remain in shell-hook.nix
- [x] Verify build
  Done when: `home-manager build` succeeds

**Changed files**: `home-manager/shell-hook.nix` (edit)

Current progress: All tasks complete.

Last updated: 2026-03-22
