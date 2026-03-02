# Design Decisions

Design decisions that affected the direction of this project.
Recorded when a considered approach was explicitly rejected.

---

## [2026-03-02] shell-hook: Explicit Opt-In, Load-Order Only

**Status**: Accepted

### Context

While planning Phase 2 (multi-shell support), we considered adding a `shell`
field to hook entries and building automatic shell-type filtering into the
`shell-hook` module. Proposed changes included:

- Adding `shell = "zsh" | "bash"` to the entry submodule
- Placing symlinks into per-shell subdirectories (`zsh/??-*.d/`, `bash/??-*.d/`)
- Generating per-shell `hook.sh` files (via extension-based or runtime shell
  detection)

### Decision

Do not add shell-type filtering to `shell-hook`. The module stays load-order
only (phases + priorities).

`config/` is organized for human readability only — it is **not**
auto-loaded. Users explicitly register desired snippets in `base.nix`. Whether
a package is installed (and thus its init snippet is needed) is entirely the
user's decision. The module must not infer loading behavior from directory
structure or file extensions.

Runtime shell detection (`$ZSH_VERSION`, `$BASH_VERSION`) in `hook.sh.tmpl` is
also unnecessary. Since users control which scripts are registered, they are
responsible for only registering shell-compatible scripts for each RC file.

### Consequences

- Phase 2 (multi-shell support) is dropped from the task plan
- Adding `.bashrc` in the future is a direct addition to `base.nix` with no
  changes to `shell-hook.nix`
- `shell-hook.nix` remains focused on load-order control only
