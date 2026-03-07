# home-manager Configuration Requirements Specification

## 1. Requirements

1. Manage tool installations across Linux (x86_64 & arm64, including WSL) and Darwin using mostly shared, declarative code
2. Do not manage the login shell
    1. Login shell selection is OS-specific and complex; coupling home-manager to it is undesirable
    2. Currently assumes zsh, but the design should accommodate bash, fish, etc.
3. Support a base + override mechanism to flexibly switch installed applications per environment
4. Keep tool configuration files lean and decoupled from home-manager — manageable as traditional shell-script-based dotfiles
5. Do not build shared modules that resolve inter-tool dependencies; support load-order control only
6. Shell plugin managers (e.g. zinit) must only be used for loading plugins — version management is handled by home-manager

---

## 2. Design Principles

1. **Limit home-manager's role**: home-manager handles only package installation and file placement. Tool configs are plain shell scripts / standard formats — `programs.*` generation is not used. Generated outputs are limited to loaders (`hook.sh`) and RC entry points (`.zshrc`)
2. **Separate package management from configuration**: Package installation (`home.packages`) and config file placement (`config/`) are separate concerns. Nix manages versions; config files remain portable and Nix-agnostic
3. **Cross-platform commonality**: Linux / Darwin differences are absorbed in `flake.nix` via system parameters and platform modules; `home.nix` and shell scripts remain maximally shared
4. **Environment-specific overrides**: Layer environment-specific deltas on top of a base package/config set using the `imports` mechanism
5. **Login-shell independence**: Login shell management is out of scope. Shell compatibility of registered scripts is the responsibility of the registering module
6. **Load-order control only**: `shell-hook` handles only load order (phases + priorities) — no inter-tool dependency resolution or tool-specific logic
7. **Explicit registration, no auto-loading**: `config/` is organized for human readability only — not auto-loaded. Hook scripts must be explicitly registered in Nix modules. `shell-hook` must not infer loading behavior from directory structure or file extensions
8. **File placement mechanism**: Use `xdg.configFile` for XDG app configs (`~/.config/`); `home.file` for home-root files (`.zshrc`, etc.). Do not use `mkOutOfStoreSymlink`
