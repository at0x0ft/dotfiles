# CLAUDE.md

## Build / Apply

```bash
# Apply configuration (run from the dotfiles directory)
home-manager switch --flake '.#at0x0ft@work'

# Or with absolute path (run from anywhere)
home-manager switch --flake '~/Programming/dotfiles#at0x0ft@work'

# Dry-run (build without activating; creates ./result symlink)
home-manager build --flake '.#at0x0ft@work'

# Update flake inputs (nixpkgs, home-manager)
nix flake update
```

## Architecture

```
flake.nix          # Entry point: named profiles, unfree allowlists, platform module wiring
  -> home.nix      # Composition root: user identity, imports, home-manager enable
       -> home-manager/base.nix               # Base packages, shell-hook entries, .zshrc generation
       -> home-manager/shell-hook.nix         # Custom module: load-order-only hook mechanism
       -> home-manager/platforms/wsl.nix      # WSL-specific packages (claude-code, etc.)
       -> home-manager/platforms/darwin.nix   # macOS-specific packages (skeleton)
       -> home-manager/platforms/linux.nix    # aarch64-linux packages (skeleton)
```

### Directory roles

| Directory | Role | Nix dependency |
|-----------|------|----------------|
| `home-manager/` | Nix components: `.nix` modules and build templates. Responsible for package installation, file placement, and load-order control. Cannot function without Nix/home-manager. | Required |
| `config/` | Portable dotfiles: plain shell scripts and app config files. Independent of Nix — deployable by any mechanism (symlinks, `stow`, manual sourcing, etc.). | None |

### shell-hook module

Provides **load-order control only** via phases and numeric priorities:

- **Phases**: defined in `shell.hook.phaseOrder` (default: `preload=0, main=1, postload=2`); extensible without modifying the module
- **Phase dirs**: named `{padded_order}-{phase}.d` (e.g. `00-preload.d`, `01-main.d`); new phases auto-sorted by glob order
- **Priority**: lower number loads first within a phase (10=early, 50=default, 90=late)
- **Naming**: symlinks as `{priority}-{filename}` (e.g. `10-zinit.zsh`)
- **Loader**: `hook.sh` generated from `home-manager/hook.sh.tmpl` via `pkgs.replaceVars`; walks `??-*.d` dirs at runtime
- **Wiring**: `.zshrc` sources `hook.sh`; hook scripts live in `config/{zsh,zinit,direnv,lsd,delta}/`

## Editing Rules

These rules apply to all edits made by Claude, without exception.

1. **Always edit both language versions together** — Whenever any Markdown file is created or modified, the counterpart file in the other language must be updated in the same operation. English files live at the repo root or under `docs/`; Japanese counterparts live under `docs/ja/` with the `.ja.md` suffix (e.g. `CLAUDE.md` ↔ `docs/ja/CLAUDE.ja.md`, `tasks.md` ↔ `docs/ja/tasks.ja.md`). Never leave one version out of sync.

## Design Constraints

See `docs/SPEC.md` for design principles and non-negotiable constraints (`docs/ja/SPEC.ja.md` for Japanese).
