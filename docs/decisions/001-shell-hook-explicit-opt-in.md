# ADR-001: shell-hook: Explicit Opt-In, Load-Order Only

- Date: 2026-03-02
- Status: Accepted

## Context

While planning Phase 2 (multi-shell support), we considered adding automatic shell-type filtering to the `shell-hook` module. Proposed changes:

- Add `shell = "zsh" | "bash"` to the entry submodule
- Place symlinks into per-shell subdirectories (`zsh/??-*.d/`, `bash/??-*.d/`)
- Generate per-shell `hook.sh` files via extension-based or runtime shell detection

## Decision

Do not add shell-type filtering to `shell-hook`. The module stays **load-order only** (phases + priorities).

- `config/` is organized for human readability only — it is **not** auto-loaded
- Users explicitly register desired snippets in `base.nix`
- Whether a package is installed (and thus its init snippet is needed) is entirely the user's decision
- The module must not infer loading behavior from directory structure or file extensions
- Runtime shell detection (`$ZSH_VERSION`, `$BASH_VERSION`) in `hook.sh.tmpl` is also unnecessary — users are responsible for only registering shell-compatible scripts

## Rationale

The shell-hook module's single responsibility is load-order control. Adding shell-type awareness violates this by coupling directory structure semantics to loading behavior. Users already have full control over what they register, making automatic filtering redundant.

## Rejected Alternatives

- **`shell = "zsh" | "bash"` field with per-shell subdirectories**
  - Introduces implicit loading rules that contradict explicit opt-in design
- **Runtime shell detection in `hook.sh.tmpl`**
  - Unnecessary since users manage registration themselves

## Consequences

- Phase 2 (multi-shell support) is dropped from the task plan
- Adding `.bashrc` in the future is a direct addition to `base.nix` with no changes to `shell-hook.nix`
- `shell-hook.nix` remains focused on load-order control only
