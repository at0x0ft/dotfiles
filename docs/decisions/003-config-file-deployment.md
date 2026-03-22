# ADR-003: Config File Deployment: xdg.configFile as Standard Mechanism

- Date: 2026-03-08
- Status: Accepted

## Context

When migrating the Neovim config to Lua format, the question arose of how application config files in `config/` should be deployed by home-manager. Options investigated:

- **`programs.*` modules** — High-level, tool-specific abstractions.
  Already rejected by project design constraint.
- **`home.file`** — Places files in `~/`.
  Appropriate for `.zshrc` but not for XDG-compliant apps reading from `~/.config/`.
- **`xdg.configFile`** — Places files in `$XDG_CONFIG_HOME` (`~/.config/`).
  Creates symlinks from the Nix store. Standard home-manager mechanism for XDG-compliant apps.
- **`mkOutOfStoreSymlink`** — Hot-reloadable, impure mode.
  Trades reproducibility for fast iteration; inconsistent with this project's pure store-based approach.

Community practice confirms `xdg.configFile` is the idiomatic choice when `programs.*` modules are not used.

## Decision

- Use `xdg.configFile` as the standard deployment mechanism for application config files targeting `~/.config/`
- Use `home.file` only for files that belong in `~/` directly
- Do not use `mkOutOfStoreSymlink`

## Rationale

`xdg.configFile` is the idiomatic home-manager mechanism for XDG-compliant apps, consistent with the project's pure store-based approach and avoids tool-specific `programs.*` abstractions.

## Rejected Alternatives

- **`programs.*` modules** — Violates project design constraint
- **`home.file`** — Not semantically correct for `~/.config/` paths
- **`mkOutOfStoreSymlink`** — Trades reproducibility for fast iteration, inconsistent with project approach

## Consequences

- All new app config deployments (e.g. Neovim, future tools) use `xdg.configFile` in `base.nix` or platform/profile modules
- `home.file` is reserved for home-root files (`.zshrc`, etc.)
- The `config/` directory remains portable and Nix-agnostic; deployment is wired in `base.nix` via `xdg.configFile`
