# Architecture

## Module Structure

```
flake.nix          # Entry point: named profiles, unfree allowlists, platform module wiring
  -> home.nix      # Composition root: user identity, imports, home-manager enable
       -> home-manager/base.nix               # Base packages, shell-hook entries, .zshrc generation
       -> home-manager/shell-hook.nix         # Custom module: load-order-only hook mechanism
       -> home-manager/platforms/wsl.nix      # WSL-specific packages (claude-code, etc.)
       -> home-manager/platforms/darwin.nix   # macOS-specific packages (skeleton)
       -> home-manager/platforms/linux.nix    # aarch64-linux packages (skeleton)
```

## Directory Roles

| Directory | Role | Nix dependency |
|-----------|------|----------------|
| `home-manager/` | Nix components: `.nix` modules and build templates. Responsible for package installation, file placement, and load-order control. Cannot function without Nix/home-manager. | Required |
| `config/` | Portable dotfiles: plain shell scripts and app config files. Independent of Nix — deployable by any mechanism (symlinks, `stow`, manual sourcing, etc.). | None |

## shell-hook Module

Provides **load-order control only** via phases and numeric priorities:

- **Phases**: defined in `shell.hook.phaseOrder` (default: `preload=0, main=1, postload=2`); extensible without modifying the module
- **Phase dirs**: named `{padded_order}-{phase}.d` (e.g. `00-preload.d`, `01-main.d`); new phases auto-sorted by glob order
- **Priority**: lower number loads first within a phase (10=early, 50=default, 90=late)
- **Naming**: symlinks as `{priority}-{filename}` (e.g. `10-zinit.zsh`)
- **Loader**: `hook.sh` generated from `home-manager/hook.sh.tmpl` via `pkgs.replaceVars`; walks `??-*.d` dirs at runtime
- **Wiring**: `.zshrc` sources `hook.sh`; hook scripts live in `config/{zsh,zinit,direnv,lsd,delta}/`

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Package management | Nix flakes + home-manager |
| Shell | Zsh (not managed as login shell) |
| Plugin manager | zinit |
| Config deployment | `xdg.configFile` (for `~/.config/`), `home.file` (for `~/`) |
