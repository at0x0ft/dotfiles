# home-manager Configuration Requirements Specification

## 1. Requirements

1. Manage tool installations across Linux (x86_64 & arm64, including WSL) and Darwin using mostly shared, declarative code
2. Keep tool configuration files lean and decoupled from home-manager — they must remain manageable as traditional shell-script-based dotfiles
3. Do not build advanced shared modules that resolve inter-tool dependencies; only support load-order control
4. Do not manage the login shell here
    1. Login shell management is complex due to OS-specific default shell interactions, which would couple home-manager to OS specifics
    2. Currently assumes zsh, but the design should work with bash, fish, etc.
5. Shell plugin managers (e.g. zinit) must only be used for loading plugins — plugin updates and version management are strictly handled by home-manager
6. Support a base + override mechanism to flexibly switch installed applications depending on the environment
7. Never delete unconfigured code — some packages lack configuration here because their config files exist elsewhere and have not been migrated yet

---

## 2. Current State Analysis

### 2.1 Project Overview

Declarative management of user `at0x0ft`'s home directory environment using Nix Flakes + Home Manager.
Currently runs on WSL2 (x86_64-linux) with Zsh as the primary shell.

### 2.2 Directory Structure

```
~/.config/home-manager/
├── flake.nix                        # Entry point (Nix Flakes)
├── flake.lock                       # Dependency version lock file
├── home.nix                         # Main Home Manager configuration
├── modules/
│   └── shell-hook.nix              # Custom module: shell hook mechanism
├── shell-hook-sources/              # Hook script source files
│   ├── zsh/                         # Zsh-specific settings
│   │   ├── zinit.zsh                # Zinit plugin manager initialization
│   │   ├── envvar.zsh               # Environment variables
│   │   ├── option.zsh               # Zsh options (history, directory)
│   │   ├── keybind.zsh              # Keybindings
│   │   └── direnv.zsh               # direnv hook (Zsh)
│   ├── common/                      # Shell-common settings
│   │   ├── delta.sh                 # diff function using delta
│   │   └── lsd.sh                   # lsd aliases
│   └── bash/                        # Bash-specific settings
│       └── direnv.bash              # direnv hook (Bash)
└── shell-hook/                     # Home Manager generated output (symlinks)
    ├── hook.sh                      # Auto-generated hook loader
    ├── main.d/
    └── postload.d/
```

### 2.3 Dependencies

| Input | Source | Purpose |
|-------|--------|---------|
| nixpkgs | `github:nixos/nixpkgs/nixos-unstable` | Package provider |
| home-manager | `github:nix-community/home-manager` | Home environment management (follows nixpkgs) |

### 2.4 Installed Packages (14)

| Package | Category | Configuration Status |
|---------|----------|---------------------|
| `claude-code` | AI tool | unfree (via dedicated pkgs-unfree) |
| `neovim` | Editor | Referenced as EDITOR in `envvar.zsh` |
| `direnv` | Environment switcher | Hooked in `direnv.zsh` / `direnv.bash` |
| `git` | VCS | Package only (config managed separately, req. 7) |
| `lsd` | ls replacement | Aliases in `lsd.sh` |
| `bat` | cat replacement | Package only (config managed separately, req. 7) |
| `fd` | find replacement | Package only (config managed separately, req. 7) |
| `delta` | diff viewer | Functions defined in `delta.sh` |
| `fzf` | Fuzzy finder | Package only (config managed separately, req. 7) |
| `zinit` | Zsh plugin manager | Initialized in `zinit.zsh` (req. 5: loader only) |
| `zsh-fzf-tab` | Zsh plugin | Package only (config managed separately, req. 7) |
| `zsh-completions` | Zsh plugin | Package only (config managed separately, req. 7) |
| `zsh-history-search-multi-word` | Zsh plugin | Package only (config managed separately, req. 7) |
| `zsh-fast-syntax-highlighting` | Zsh plugin | Package only (config managed separately, req. 7) |

### 2.5 shell-hook Module Design

A simple module aligned with requirement 3, handling only load-order control:

- **3-phase structure**: `preload.d` -> `main.d` -> `postload.d`
- **Priority control**: loaded in ascending numeric order (10: first, 50: default, 90: last)
- **Naming convention**: `{priority}-{filename}` (e.g. `10-zinit.zsh`, `50-envvar.zsh`)
- **Symlink-based**: places symlinks to Nix store files via `xdg.configFile`
- **Loader (`hook.sh`)**: auto-generated script that walks each phase directory and sources files

### 2.6 Requirements Compliance Analysis

| Requirement | Current Compliance | Details |
|-------------|-------------------|---------|
| Req. 1: Cross-platform | **Non-compliant** | `system = "x86_64-linux"` is hardcoded in `flake.nix`. No mechanism for arm64-linux, aarch64-darwin, etc. |
| Req. 2: Lean dotfiles | **Compliant** | Tool configs are plain shell scripts in `shell-hook-sources/`, independent of home-manager. No `programs.*` usage |
| Req. 3: Simple modules | **Compliant** | `shell-hook.nix` implements only load-order control, no inter-tool dependency resolution |
| Req. 4: No login shell management | **Mostly compliant** | Does not use `programs.zsh`, generates `.zshrc` directly. However, `.zshrc` generation and some scripts (`zsh/`) are Zsh-specific, with no equivalent path for bash/fish |
| Req. 5: Plugin manager as loader only | **Compliant** | zinit is used only for sourcing plugins in `zinit.zsh`. Package version management is strict via `home.packages` + `flake.lock` |
| Req. 6: Base + override | **Non-compliant** | All packages are listed flat in `home.nix`, no environment-specific switching mechanism |
| Req. 7: Preserve unconfigured code | **Compliant** | Packages with configs managed elsewhere (bat, fd, fzf, etc.) are preserved |

---

## 3. Design Principles

1. **Limit home-manager's role**: home-manager handles only "package management" and "file placement". Tool configuration files are written as plain shell scripts / standard formats — `programs.*` config generation is not used. home-manager may only generate loaders (`hook.sh`) and rc file entry points (`.zshrc`)
2. **Load-order control only**: The `shell-hook` module handles only load order (phases + priorities), with no inter-tool dependency resolution or tool-specific logic
3. **Separate package management from configuration**: Package installation (`home.packages`) and config file placement (`shell-hook-sources/`) are separate concerns. Nix strictly manages package versions; config files remain portable
4. **Cross-platform commonality**: Linux (x86_64, arm64) / Darwin differences are absorbed via `flake.nix` system parameters and module conditionals; `home.nix` and shell scripts remain maximally shared
5. **Environment-specific overrides**: Layer environment-specific deltas on top of a base package/config set. Leverage `imports` and Nix module system's `mkDefault` / `mkForce`
6. **Login-shell independence**: Login shell management is out of scope; handled via rc file placement (`.zshrc`, etc.). Enforce separation between shell-common scripts (`common/`) and shell-specific scripts (`zsh/`, `bash/`)
7. **Add, don't delete**: Preserve unconfigured packages and scripts for future configuration migration. Delete only when explicitly deemed unnecessary

---

## 4. Improvement Policies

### 4.1 Cross-Platform Support (Req. 1)

Currently `system = "x86_64-linux"` is hardcoded in `flake.nix`.

**Policy**: Make `flake.nix` outputs support multiple systems.

```
flake.nix (target state)
├── supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]
├── Generate homeConfigurations per system
└── Absorb system/OS-specific package differences via conditionals or override modules
```

- Use `nixpkgs.lib.genAttrs` or `flake-utils` to enumerate multiple systems
- Generate `homeConfigurations."at0x0ft@${system}"` per system
- Shell scripts (`shell-hook-sources/`) require no changes (already portable)

### 4.2 Environment-Specific Override Mechanism (Req. 6)

Currently all packages/configs are flat in `home.nix` with no environment-specific management.

**Policy**: Introduce a base module + environment-specific override module layering.

```
modules/
├── shell-hook.nix                  # Existing: hook mechanism (shared foundation)
├── base.nix                         # New: cross-environment common packages + config
└── overrides/
    ├── wsl.nix                      # New: WSL-specific additions/overrides
    └── darwin.nix                   # New: macOS-specific additions/overrides
```

- `base.nix`: Common packages across all environments (git, neovim, fzf, etc.) and common hooks
- `overrides/*.nix`: Environment-specific additional packages, unfree allowlists, OS-specific hooks, etc.
- `flake.nix`: Add appropriate override modules to `imports` based on system / hostname

### 4.3 Refactor home.nix (Prerequisite for Req. 1, 6)

Currently `home.nix` handles package definitions, hook entries, and `.zshrc` generation all at once.

**Policy**: Reduce `home.nix` to module composition via `imports` and minimal user information only.

```
home.nix (target state)
├── home.username / home.homeDirectory / home.stateVersion
├── imports = [ ./modules/shell-hook.nix ./modules/base.nix ./modules/overrides/... ]
└── programs.home-manager.enable = true
```

- Package list -> move to `base.nix` + override modules
- Hook entries -> move to corresponding modules (`base.nix`, etc.)
- `.zshrc` generation -> consider moving to a shell-init dedicated module (grouping per-shell rc generation per req. 4)

### 4.4 Multi-Shell RC File Generation (Req. 4)

Currently only `.zshrc` is generated; no rc file generation path for bash/fish.
`bash/direnv.bash` exists but is not registered in `shell.hook.entries`.

**Policy**: Organize per-shell rc file generation and hook entry registration.

- `.zshrc`: Maintain current behavior (source zsh hooks)
- `.bashrc`: Consider adding similar loader structure to source bash hooks
- The `common/` / `zsh/` / `bash/` separation in `shell-hook-sources/` is already appropriate
- Consider adding a shell-type tag to hook entries in `shell-hook.nix` so each shell loads only its appropriate hooks

### 4.5 shell-hook Module Improvement (Req. 3)

Address the TODO comment in the module (`# TODO: refactor as config.xdg.configFile.(...).target;`).

**Policy**: Clean up `xdg.configFile` usage while maintaining simplicity (req. 3).

- Already using `xdg.configFile`, so the TODO likely refers to option structure cleanup
- Make `baseDir` option consistent as the `xdg.configFile` target path
- Maintain simple phase/priority load-order control (adhere to req. 3)

### 4.6 Unfree Package Handling (Derived from Req. 1, 6)

Currently `flake.nix` only allows `claude-code` as unfree.

**Policy**: Make the unfree allowlist overridable.

- Base: empty list; override: allow environment-specific unfree packages
- Generate `pkgs-unfree` dynamically based on system
