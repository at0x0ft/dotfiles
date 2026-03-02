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

---

## [2026-03-03] Profile System: profileDefs-based Named Profiles (Case A)

**Status**: Accepted

### Context

When introducing user-facing named profiles, three implementation approaches were considered:

- **Case A**: Define `profileDefs` in `flake.nix` mapping profile names to `{system, env}`;
  generate `homeConfigurations` as `at0x0ft@${profileName}`; module stack includes
  a dedicated `profiles/${name}.nix`.
- **Case B**: Keep system-based keys (`at0x0ft@${system}`), pass profile as
  `extraSpecialArgs`; add profile-named alias keys alongside system keys.
- **Case C**: Embed the full module list per profile directly in `profileDefs`
  (self-describing but verbose).

Also decided to rename `home-manager/overrides/` to `home-manager/platforms/` to better
reflect its role as OS + CPU arch definitions rather than "overrides on top of base".

### Decision

Adopt Case A. `profileDefs` replaces `systemEnvironment` as the single source of truth
for configuration generation. Profile names (`work`, `individual`) become the user-facing
flake output keys. The `platforms/` (OS+arch) and `profiles/` (user-specific) directories
form a clear two-layer override hierarchy on top of `base.nix`.

Case B was rejected: maintaining dual key structures (system keys + profile aliases)
creates confusion about which key to use.
Case C was rejected: embedding the full module list in `profileDefs` makes `flake.nix`
verbose and hard to maintain as profiles grow.

### Consequences

- `homeConfigurations` no longer contains system-string keys; all keys are profile names
- `systemEnvironment` map is replaced by the `env` field within each `profileDefs` entry
- Adding a new profile = one entry in `profileDefs` + one skeleton `.nix` in `profiles/`
- `overrides/` is renamed to `platforms/` (Phase 3.1)
- Module stack per profile: `home.nix` + `base.nix` + `platforms/${env}.nix` + `profiles/${name}.nix`
