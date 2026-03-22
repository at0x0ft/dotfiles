# Phase 2: Cross-Platform & Environment-Specific Support

## 2.1 Multi-System Support in flake.nix (Policy 4.1)

**Goal**: Enable builds on systems other than x86_64-linux (aarch64-linux, aarch64-darwin).

- [x] Define `supportedSystems` list
  Done when: `[ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]` is defined
- [x] Use `builtins.listToAttrs + map` to generate `homeConfigurations` per system
  Done when: homeConfigurations are generated dynamically
- [x] Generate `pkgs-unfree` dynamically per system
  Done when: each system gets its own pkgs-unfree
- [x] Pass `isDarwin` / `isLinux` flags via `extraSpecialArgs`
  Done when: modules can branch on platform
- [x] Verify build on existing x86_64-linux
  Done when: `home-manager build --flake '.#at0x0ft@x86_64-linux'` succeeds

**Changed files**: `flake.nix` (edit)

---

## 2.2 Introduce Environment-Specific Override Mechanism (Policy 4.2)

**Goal**: Layer environment-specific deltas on top of a base package set.

- [x] Create `home-manager/overrides/` directory
  Done when: directory exists
- [x] Create `home-manager/overrides/wsl.nix` with WSL-specific packages
  Done when: claude-code is in wsl.nix
- [x] Create `home-manager/overrides/darwin.nix` (skeleton)
  Done when: skeleton file exists
- [x] Create `home-manager/overrides/linux.nix` (skeleton)
  Done when: skeleton file exists
- [x] Wire override modules in `flake.nix` based on system/environment
  Done when: override module is included in modules list
- [x] Verify build
  Done when: `home-manager build` succeeds

**Changed files**: `flake.nix` (edit), `home-manager/overrides/*.nix` (new)

---

## 2.3 Unfree Package Handling Cleanup (Policy 4.6)

**Goal**: Make the unfree allowlist overridable.

- [x] Make unfree allowlist injectable per environment
  Done when: `unfreeAllowlists` attr set exists in flake.nix
- [x] Generate `pkgs-unfree` dynamically based on both allowlist and system
  Done when: pkgs-unfree uses merged allowlists
- [x] Verify build
  Done when: `home-manager build` succeeds

**Changed files**: `flake.nix` (edit), `home-manager/overrides/wsl.nix` (edit)

Current progress: All tasks complete.

Last updated: 2026-03-22
