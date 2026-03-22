# Phase 4: zinit Integration

## 4.1 zinit Module (`home-manager/zinit.nix`)

**Goal**: Abstract zinit initialization and plugin loading into a dedicated module, removing implementation details from `base.nix`.

- [ ] Create `home-manager/zinit-init.zsh.tmpl`
  Done when: template contains `source "@zinit_path@/zinit.zsh"`
- [ ] Create `home-manager/zinit.nix`
  Done when: module defines `zsh.zinit.enable`, `zsh.zinit.plugins`, and registers hook entries
- [ ] Update `home.nix`: replace `./home-manager/shell-hook.nix` with `./home-manager/zinit.nix`
  Done when: shell-hook is pulled in transitively via zinit.nix
- [ ] Update `home-manager/base.nix`: remove `pkgs.zinit` from packages, remove zinit hook entry, add `zsh.zinit.enable = true` and `zsh.zinit.plugins = [...]`
  Done when: base.nix uses the zinit module interface only
- [ ] Keep `config/zinit/zinit.zsh` as non-Nix standalone fallback (no change)
  Done when: file is unchanged
- [ ] Verify build
  Done when: `home-manager build --flake '.#at0x0ft@work'` succeeds

**Changed files**: `home-manager/zinit.nix` (new), `home-manager/zinit-init.zsh.tmpl` (new), `home.nix` (edit), `home-manager/base.nix` (edit)

Current progress: Not started.

Last updated: 2026-03-22
