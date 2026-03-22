# ADR-004: zinit Module: Namespace, Architecture, and Plugin Extensibility

- Date: 2026-03-08
- Status: Accepted

## Context

When designing the zinit Nix module (Phase 4.1), several decisions were needed:

- **Namespace**: Candidates were `shell.zinit`, flat `zinit.enable`, and `zsh.zinit`
- **Architecture**: Inline `pkgs.writeText` in `base.nix` vs. a dedicated module with template (mirroring shell-hook pattern)
- **Plugin loading**: Must support multiple load verbs (`snippet`, `light`, `load`) and arbitrary ice modifiers — a simple `plugins = [package]` list cannot express these
- **Module dependency**: `zinit.nix` uses `shell.hook.entries` from `shell-hook.nix`, requiring explicit declaration

## Decision

1. **Namespace → `zsh.zinit`**
   - zinit is zsh-specific, not shell-agnostic
   - `zsh.*` namespace provides a natural home for all zsh-specific plugins
2. **Architecture → template + module** (mirroring shell-hook pattern)
   - `zinit.nix` encapsulates implementation details
   - `zinit-init.zsh.tmpl` processed via `pkgs.replaceVars` (init script)
   - Dynamic plugin list generated via `pkgs.writeText` (Nix string interpolation)
   - Two hook entries: priority 10 (init) and priority 20 (plugins)
3. **Plugin option → submodule with `verb`, `path`, `ices`**
   - Maps directly to zinit's command structure: `zi ice <ices...>` then `zi <verb> <path>`
   - Covers all current use cases; extensible without module changes
4. **Module dependency → explicit `imports`**
   - `zinit.nix` declares `imports = [ ./shell-hook.nix ]`
   - Nix module system deduplicates identical imports, so safe even when caller also imports `shell-hook.nix`

## Rationale

- `zsh.zinit` correctly scopes the module to zsh
- The template + module pattern keeps `base.nix` clean of implementation details
- The submodule approach covers all current use cases and remains extensible without module changes

## Rejected Alternatives

- **`shell.zinit`** — zinit has no meaning outside zsh
- **Flat `zinit.enable`** — No namespace for future zsh-specific modules
- **Inline `pkgs.writeText` in `base.nix`** — Exposes implementation details at the composition layer
- **Simple `plugins = [package]` list** — Cannot express different load verbs or ice modifiers

## Consequences

- `base.nix` declares `zsh.zinit.enable = true` and `zsh.zinit.plugins = [...]`; no Nix store paths or zinit commands appear there
- `home.nix` imports only `zinit.nix`; `shell-hook.nix` is pulled in transitively
- `config/zinit/zinit.zsh` is kept as a non-Nix standalone fallback (no change)
- The `zsh.*` namespace is now established for future zsh-specific modules (e.g., per-plugin modules)
