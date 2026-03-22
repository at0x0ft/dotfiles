# ADR-002: Profile System: profileDefs-based Named Profiles (Case A)

- Date: 2026-03-03
- Status: Accepted

## Context

When introducing user-facing named profiles, three implementation approaches were considered:

- **Case A**: Define `profileDefs` in `flake.nix` mapping profile names to `{system, env}`;
  generate `homeConfigurations` as `at0x0ft@${profileName}`;
  module stack includes a dedicated `profiles/${name}.nix`
- **Case B**: Keep system-based keys (`at0x0ft@${system}`), pass profile as `extraSpecialArgs`;
  add profile-named alias keys alongside system keys
- **Case C**: Embed the full module list per profile directly in `profileDefs`
  (self-describing but verbose)

Also decided to rename `home-manager/overrides/` to `home-manager/platforms/` to better reflect its role as OS + CPU arch definitions.

## Decision

Adopt **Case A**.

- `profileDefs` replaces `systemEnvironment` as the single source of truth for configuration generation
- Profile names (`work`, `individual`) become the user-facing flake output keys
- `platforms/` (OS+arch) and `profiles/` (user-specific) form a clear two-layer override hierarchy on top of `base.nix`

## Rationale

Case A provides the cleanest separation: one entry in `profileDefs` + one skeleton `.nix` in `profiles/` to add a new profile. The profile name becomes the single user-facing key.

## Rejected Alternatives

- **Case B** — Maintaining dual key structures (system keys + profile aliases) creates confusion about which key to use
- **Case C** — Embedding the full module list in `profileDefs` makes `flake.nix` verbose and hard to maintain as profiles grow

## Consequences

- `homeConfigurations` no longer contains system-string keys; all keys are profile names
- `systemEnvironment` map is replaced by the `env` field within each `profileDefs` entry
- Adding a new profile = one entry in `profileDefs` + one skeleton `.nix` in `profiles/`
- `overrides/` is renamed to `platforms/` (Phase 3.1)
- Module stack per profile: `home.nix` + `base.nix` + `platforms/${env}.nix` + `profiles/${name}.nix`
