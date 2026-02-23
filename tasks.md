# Task Plan

Task breakdown based on plan.md Section 4 (Improvement Policies).
Listed in execution order considering dependencies.

---

## Phase 1: Foundation (Prerequisites for Other Tasks)

### 1.1 Split home.nix (Policy 4.3)

**Goal**: Minimize home.nix responsibilities, creating the foundation for environment-specific overrides (4.2) and multi-shell support (4.4).

**Current state**: home.nix handles package definitions, hook entries, and .zshrc generation all at once.

**Tasks**:

- [ ] Create `modules/base.nix`
  - Move `home.packages` list from home.nix
  - Move `shell.hooks.entries` list from home.nix
  - Move `.zshrc` generation logic from home.nix
- [ ] Reduce home.nix to minimal composition
  - `home.username` / `home.homeDirectory` / `home.stateVersion`
  - `imports = [ ./modules/shell-hooks.nix ./modules/base.nix ]`
  - `programs.home-manager.enable = true`
- [ ] Verify no-diff build with `home-manager build --flake .#at0x0ft` (preserve existing behavior)

**Changed files**: `home.nix` (edit), `modules/base.nix` (new)

**Note**: Ensure `pkgs-unfree` argument passing works in base.nix by maintaining the `extraSpecialArgs` pathway.

---

### 1.2 Clean Up shell-hooks Module (Policy 4.5)

**Goal**: Resolve the TODO comment and improve `baseDir` option consistency.

**Current state**: `# TODO: refactor as config.xdg.configFile.(...).target;` remains.

**Tasks**:

- [ ] Clarify `baseDir` option usage as the `xdg.configFile` target path
  - Already placing files via `xdg.configFile`, so confirm the TODO's intent and clean up
- [ ] Resolve the TODO comment (refactor or remove)
- [ ] Do not modify phase/priority control logic (req. 3: keep it simple)
- [ ] Verify build

**Changed files**: `modules/shell-hooks.nix` (edit)

---

## Phase 2: Multi-Shell Support

### 2.1 Add Shell-Type Tag to shell-hooks (Policy 4.4, first half)

**Goal**: Add a shell-type attribute to hook entries so each shell loads only its appropriate hooks.

**Current state**: All entries are loaded without distinction. `shell-hook-sources/` is already separated into `zsh/`, `common/`, `bash/`.

**Tasks**:

- [ ] Add `shell` option to entry submodule in `shell-hooks.nix`
  - Type: `types.enum [ "common" "zsh" "bash" ]` (or list type)
  - Default: `"common"`
- [ ] Extend config to place symlinks in per-shell directories
  - e.g. `shell-hooks/zsh/main.d/`, `shell-hooks/common/main.d/`
- [ ] Update `hook.sh` generation logic for shell-type awareness
  - zsh loader: walks common + zsh directories
  - bash loader: walks common + bash directories
- [ ] Add `shell` tags to existing `shell.hooks.entries` (in home.nix or base.nix)
- [ ] Verify build

**Changed files**: `modules/shell-hooks.nix` (edit), `modules/base.nix` (edit)

**Note**: Adhere to req. 3 — no inter-tool dependency resolution. Only shell-type filtering.

---

### 2.2 Multi-Shell RC File Generation (Policy 4.4, second half)

**Goal**: Generate `.bashrc` and other loader entry points so shell-hooks work in bash too.

**Current state**: Only `.zshrc` is generated. `bash/direnv.bash` exists but is not registered in `shell.hooks.entries`.

**Tasks**:

- [ ] Generate `.bashrc` via `home.file` (same loader structure as `.zshrc`)
  - Source bash-specific `hook.sh` (common + bash hooks)
- [ ] Register `bash/direnv.bash` in `shell.hooks.entries` (`shell = "bash"`)
- [ ] Consider extracting rc file generation into a dedicated module (e.g. `modules/shell-rc.nix`)
- [ ] Test in both shells (`zsh`, `bash`)

**Changed files**: `modules/base.nix` (edit), possibly `modules/shell-rc.nix` (new)

**Note**: Req. 4 — do not manage login shells. Only place rc files.

---

## Phase 3: Cross-Platform & Environment-Specific Support

### 3.1 Multi-System Support in flake.nix (Policy 4.1)

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

**Note**: `shell-hook-sources/` requires no changes (already portable).

---

### 3.2 Introduce Environment-Specific Override Mechanism (Policy 4.2)

**Goal**: Layer environment-specific deltas on top of a base package set.

**Current state**: All packages are listed flat with no environment-specific switching.

**Tasks**:

- [ ] Create `modules/overrides/` directory
- [ ] Create `modules/overrides/wsl.nix`
  - WSL-specific additional packages (e.g. `claude-code` for WSL only)
  - WSL-specific hook entries (if any)
- [ ] Create `modules/overrides/darwin.nix` (skeleton)
  - macOS-specific additional packages
  - macOS-specific hook entries
- [ ] In `flake.nix`, add appropriate override modules to `imports` based on system/environment
  - Pass `isDarwin` / `isLinux` flags via `extraSpecialArgs`
- [ ] Verify build

**Changed files**: `flake.nix` (edit), `modules/overrides/wsl.nix` (new), `modules/overrides/darwin.nix` (new)

---

### 3.3 Unfree Package Handling Cleanup (Policy 4.6)

**Goal**: Make the unfree allowlist overridable.

**Current state**: `flake.nix` only allows `claude-code`.

**Tasks**:

- [ ] Make unfree allowlist injectable from override modules
  - Base: empty list
  - Override (e.g. `wsl.nix`): `[ "claude-code" ]`, etc.
- [ ] Generate `pkgs-unfree` dynamically based on both allowlist and system
- [ ] Verify build

**Changed files**: `flake.nix` (edit), `modules/overrides/wsl.nix` (edit)

**Note**: Tightly linked with 3.1 and 3.2 — best implemented together.

---

## Dependency Summary

```
Phase 1 (Foundation)
  1.1 Split home.nix ──────────┐
  1.2 Clean up shell-hooks ────┤
                               v
Phase 2 (Multi-shell)          │
  2.1 Shell-type tag ──────────┤ (depends on 1.2)
  2.2 Multi-shell rc gen ──────┤ (depends on 1.1, 2.1)
                               v
Phase 3 (Cross-platform)
  3.1 Multi-system support ────┤ (depends on 1.1)
  3.2 Environment overrides ───┤ (depends on 1.1, 3.1)
  3.3 Unfree cleanup ──────────┘ (depends on 3.1, 3.2)
```

## Common Constraints

The following must be observed across all tasks:

- **Do not use `programs.*`** (only exception: `programs.home-manager.enable`)
- **Do not manage login shells**
- **Do not delete unconfigured packages/code**
- **Keep the shell-hooks module simple** (load-order control only)
- Verify existing behavior with `home-manager build` after completing each task
