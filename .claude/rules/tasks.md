# Task Plan

Task breakdown based on docs/SPEC.md Section 4 (Improvement Policies).
Listed in execution order considering dependencies.

---

## Phase 1: Foundation (Prerequisites for Other Tasks)

### 1.1 Split home.nix (Policy 4.3)

**Goal**: Minimize home.nix responsibilities, creating the foundation for environment-specific overrides (4.2) and multi-shell support (4.4).

**Current state**: home.nix handles package definitions, hook entries, and .zshrc generation all at once.

**Tasks**:

- [x] Create `home-manager/base.nix`
  - Move `home.packages` list from home.nix
  - Move `shell.hook.entries` list from home.nix
  - Move `.zshrc` generation logic from home.nix
- [x] Reduce home.nix to minimal composition
  - `home.username` / `home.homeDirectory` / `home.stateVersion`
  - `imports = [ ./home-manager/shell-hook.nix ./home-manager/base.nix ]`
  - `programs.home-manager.enable = true`
- [x] Verify no-diff build with `home-manager build --flake .#at0x0ft` (preserve existing behavior)

**Changed files**: `home.nix` (edit), `home-manager/base.nix` (new)

**Note**: Ensure `pkgs-unfree` argument passing works in base.nix by maintaining the `extraSpecialArgs` pathway.

---

### 1.2 Clean Up shell-hook Module (Policy 4.5)

**Goal**: Resolve the TODO comment and improve `baseDir` option consistency.

**Current state**: `# TODO: refactor as config.xdg.configFile.(...).target;` remains.

**Tasks**:

- [x] Clarify `baseDir` option usage as the `xdg.configFile` target path
  - Already placing files via `xdg.configFile`, so confirm the TODO's intent and clean up
- [x] Resolve the TODO comment (refactor or remove)
- [x] Do not modify phase/priority control logic (req. 3: keep it simple)
- [x] Verify build

**Changed files**: `home-manager/shell-hook.nix` (edit)

---

## Phase 2: Cross-Platform & Environment-Specific Support

### 2.1 Multi-System Support in flake.nix (Policy 4.1)

**Goal**: Enable builds on systems other than x86_64-linux (aarch64-linux, aarch64-darwin).

**Current state**: `system = "x86_64-linux"` is hardcoded.

**Tasks**:

- [ ] Define `supportedSystems` list
  - `[ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]`
- [ ] Use `nixpkgs.lib.genAttrs` etc. to generate `homeConfigurations` per system
  - Naming: `"at0x0ft@${system}"` or switch `"at0x0ft"` by system argument
- [ ] Generate `pkgs-unfree` dynamically per system (linked with 4.6)
- [ ] Pass `system` info via `extraSpecialArgs` so modules can branch conditionally
- [ ] Verify build on existing x86_64-linux (`home-manager build --flake .#at0x0ft@x86_64-linux`)

**Changed files**: `flake.nix` (edit)

**Note**: `config/` requires no changes (already portable).

---

### 2.2 Introduce Environment-Specific Override Mechanism (Policy 4.2)

**Goal**: Layer environment-specific deltas on top of a base package set.

**Current state**: All packages are listed flat with no environment-specific switching.

**Tasks**:

- [ ] Create `home-manager/overrides/` directory
- [ ] Create `home-manager/overrides/wsl.nix`
  - WSL-specific additional packages (e.g. `claude-code` for WSL only)
  - WSL-specific hook entries (if any)
- [ ] Create `home-manager/overrides/darwin.nix` (skeleton)
  - macOS-specific additional packages
  - macOS-specific hook entries
- [ ] In `flake.nix`, add appropriate override modules to `imports` based on system/environment
  - Pass `isDarwin` / `isLinux` flags via `extraSpecialArgs`
- [ ] Verify build

**Changed files**: `flake.nix` (edit), `home-manager/overrides/wsl.nix` (new), `home-manager/overrides/darwin.nix` (new)

---

### 2.3 Unfree Package Handling Cleanup (Policy 4.6)

**Goal**: Make the unfree allowlist overridable.

**Current state**: `flake.nix` only allows `claude-code`.

**Tasks**:

- [ ] Make unfree allowlist injectable from override modules
  - Base: empty list
  - Override (e.g. `wsl.nix`): `[ "claude-code" ]`, etc.
- [ ] Generate `pkgs-unfree` dynamically based on both allowlist and system
- [ ] Verify build

**Changed files**: `flake.nix` (edit), `home-manager/overrides/wsl.nix` (edit)

**Note**: Tightly linked with 3.1 and 3.2 — best implemented together.

---

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
```

## Common Constraints

The following must be observed across all tasks:

- **Do not use `programs.*`** (only exception: `programs.home-manager.enable`)
- **Do not manage login shells**
- **Do not delete unconfigured packages/code**
- **Keep the shell-hook module simple** (load-order control only)
- Verify existing behavior with `home-manager build` after completing each task
