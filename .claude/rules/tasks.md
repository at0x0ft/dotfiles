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

- [x] Define `supportedSystems` list
  - `[ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]`
- [x] Use `builtins.listToAttrs + map` to generate `homeConfigurations` per system
  - Naming: `"at0x0ft@${system}"`
- [x] Generate `pkgs-unfree` dynamically per system (linked with 4.6)
- [x] Pass `isDarwin` / `isLinux` flags via `extraSpecialArgs` so modules can branch conditionally
- [x] Verify build on existing x86_64-linux (`home-manager build --flake '.#at0x0ft@x86_64-linux'`)

**Changed files**: `flake.nix` (edit)

**Note**: `config/` requires no changes (already portable).

---

### 2.2 Introduce Environment-Specific Override Mechanism (Policy 4.2)

**Goal**: Layer environment-specific deltas on top of a base package set.

**Current state**: All packages are listed flat with no environment-specific switching.

**Tasks**:

- [x] Create `home-manager/overrides/` directory
- [x] Create `home-manager/overrides/wsl.nix`
  - WSL-specific additional packages (`claude-code`)
- [x] Create `home-manager/overrides/darwin.nix` (skeleton)
  - macOS-specific additional packages
- [x] Create `home-manager/overrides/linux.nix` (skeleton, aarch64-linux)
- [x] In `flake.nix`, add override modules to `modules` list based on system/environment
  - Pass `isDarwin` / `isLinux` flags via `extraSpecialArgs`
- [x] Verify build

**Changed files**: `flake.nix` (edit), `home-manager/overrides/wsl.nix` (new), `home-manager/overrides/darwin.nix` (new), `home-manager/overrides/linux.nix` (new)

---

### 2.3 Unfree Package Handling Cleanup (Policy 4.6)

**Goal**: Make the unfree allowlist overridable.

**Current state**: `flake.nix` only allows `claude-code`.

**Tasks**:

- [x] Make unfree allowlist injectable per environment
  - `unfreeAllowlists` attr set in `flake.nix`: base = `[]`, wsl = `["claude-code"]`
  - Note: allowlist stays in `flake.nix` (must be defined before module evaluation)
- [x] Generate `pkgs-unfree` dynamically based on both allowlist and system
- [x] Verify build

**Changed files**: `flake.nix` (edit), `home-manager/overrides/wsl.nix` (edit)

**Note**: Tightly linked with 2.1 and 2.2 — best implemented together.

---

## Phase 3: Named Profile System

### 3.1 Rename `overrides/` to `platforms/` (Policy 4.7)

**Goal**: Clarify the directory's role as OS + CPU arch platform definitions.

**Current state**: `home-manager/overrides/` — name implies overriding but not platform identity.

**Tasks**:

- [x] Rename `home-manager/overrides/` to `home-manager/platforms/`
- [x] Update all references in `flake.nix`
- [x] Verify build

**Changed files**: `home-manager/platforms/` (rename from `overrides/`), `flake.nix` (edit)

---

### 3.2 Introduce `profileDefs` and Profile-based `homeConfigurations` (Policy 4.7)

**Goal**: Replace system-string keys with named user profiles.

**Current state**: `homeConfigurations` keys are `at0x0ft@${system}` (e.g. `at0x0ft@x86_64-linux`).

**Tasks**:

- [x] Define `profileDefs` in `flake.nix`
  - Example: `work = { system = "x86_64-linux"; env = "wsl"; }`
- [x] Update `makeHomeConfig` to accept profile name and include `profiles/${name}.nix`
- [x] Change key generation to `"at0x0ft@${profileName}"`
- [x] Verify build: `home-manager build --flake '.#at0x0ft@work'`

**Changed files**: `flake.nix` (edit)

---

### 3.3 Create `profiles/` Directory with Initial Profiles (Policy 4.7)

**Goal**: Add initial user profile modules.

**Current state**: No `profiles/` directory exists.

**Tasks**:

- [x] Create `home-manager/profiles/work.nix` (skeleton)
- [x] Create `home-manager/profiles/individual.nix` (skeleton)
- [x] Verify build for all profiles

**Changed files**: `home-manager/profiles/work.nix` (new), `home-manager/profiles/individual.nix` (new)

---

## Phase 4: zinit Integration

### 4.1 zinit Module (`home-manager/zinit.nix`)

**Goal**: Abstract zinit initialization and plugin loading into a dedicated module, removing implementation details from `base.nix`.

**Tasks**:

- [ ] Create `home-manager/zinit-init.zsh.tmpl`
  - Template: `source "@zinit_path@/zinit.zsh"`
- [ ] Create `home-manager/zinit.nix`
  - `imports = [ ./shell-hook.nix ]` to declare dependency explicitly
  - `options.zsh.zinit.enable` (`mkEnableOption`)
  - `options.zsh.zinit.plugins` — list of submodule with `verb` (enum: snippet/light/load), `path` (str), `ices` (list of str)
  - `config`: add `pkgs.zinit` to `home.packages`, register two hook entries (priority 10: init via `pkgs.replaceVars`, priority 20: plugins via `pkgs.writeText`; omit if plugins list is empty)
- [ ] Update `home.nix`: replace `./home-manager/shell-hook.nix` with `./home-manager/zinit.nix` (shell-hook is pulled in transitively)
- [ ] Update `home-manager/base.nix`: remove `pkgs.zinit` from packages, remove zinit hook entry, add `zsh.zinit.enable = true` and `zsh.zinit.plugins = [...]`
- [ ] Keep `config/zinit/zinit.zsh` as non-Nix standalone fallback (no change)
- [ ] Verify build

**Changed files**: `home-manager/zinit.nix` (new), `home-manager/zinit-init.zsh.tmpl` (new), `home.nix` (edit), `home-manager/base.nix` (edit)

---

## Phase 5: Neovim Config Migration

### 5.1 Migrate `config/neovim/rc.vim` to Lua

**Goal**: Modernize the Neovim config from VimScript to Lua format, and wire up deployment via `xdg.configFile` in `base.nix`.

**Current state**: `config/neovim/rc.vim` is a VimScript file with Vim-compatibility settings; not yet deployed by Nix.

**Tasks**:

- [ ] Create `config/neovim/init.lua` (entry point: `require("options")` and `require("keymaps")`)
- [ ] Create `config/neovim/lua/options.lua`
  - Convert all `set ...` to `vim.opt.*`
  - Remove Neovim-default settings (`nocompatible`, `fenc=utf-8`, etc.)
  - Update highlight settings to `vim.api.nvim_set_hl()`
  - Update `laststatus` to 3 (global statusline, Neovim 0.7+)
- [ ] Create `config/neovim/lua/keymaps.lua`
  - Convert `nmap` to `vim.keymap.set()`
- [ ] Add `xdg.configFile."nvim"` entry in `home-manager/base.nix`
  - Deploy `config/neovim/` directory recursively to `~/.config/nvim/`
- [ ] Remove `config/neovim/rc.vim`
- [ ] Verify build

**Changed files**: `config/neovim/init.lua` (new), `config/neovim/lua/options.lua` (new), `config/neovim/lua/keymaps.lua` (new), `config/neovim/rc.vim` (delete), `home-manager/base.nix` (edit)

---

## Phase 6: Backlog

### 6.1 Extract Reusable Modules to Separate Repository

**Goal**: Publish `shell-hook` and `zinit` modules as a standalone flake for reuse by other users.

**Background**: These modules (shell-hook, zinit) are general-purpose and not specific to this dotfiles repo. Extracting them improves reusability and allows other users to consume them as a flake input.

**Tasks** (rough scope, TBD):

- [ ] Create a new repository (e.g., `nix-zsh-modules` or similar)
- [ ] Move `home-manager/shell-hook.nix` + `hook.sh.tmpl`
- [ ] Move `home-manager/zinit.nix` + `zinit-init.zsh.tmpl`
- [ ] Expose as a home-manager module via flake outputs
- [ ] Update this dotfiles repo to consume the new flake as an input
- [ ] Write minimal documentation / README

**Note**: Implement after zinit module (4.1) is stable and the module interface is confirmed.

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
