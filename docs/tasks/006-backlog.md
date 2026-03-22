# Phase 6: Backlog

## 6.1 Extract Reusable Modules to Separate Repository

**Goal**: Publish `shell-hook` and `zinit` modules as a standalone flake for reuse by other users.

**Background**: These modules (shell-hook, zinit) are general-purpose and not specific to this dotfiles repo. Extracting them improves reusability and allows other users to consume them as a flake input.

- [ ] Create a new repository (e.g., `nix-zsh-modules` or similar)
  Done when: repository exists with initial structure
- [ ] Move `home-manager/shell-hook.nix` + `hook.sh.tmpl`
  Done when: files are in the new repository
- [ ] Move `home-manager/zinit.nix` + `zinit-init.zsh.tmpl`
  Done when: files are in the new repository
- [ ] Expose as a home-manager module via flake outputs
  Done when: flake.nix exports the modules
- [ ] Update this dotfiles repo to consume the new flake as an input
  Done when: dotfiles flake.nix uses the external modules
- [ ] Write minimal documentation / README
  Done when: README explains usage

**Note**: Implement after zinit module (4.1) is stable and the module interface is confirmed.

Current progress: Not started.

Last updated: 2026-03-22
