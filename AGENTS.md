# AGENTS.md

Nix + home-manager based cross-platform dotfiles with load-order-controlled shell hooks.

## Reference Documents

See @docs/SPEC.md for requirements and design principles.
See @docs/ARCHITECTURE.md for module structure and directory roles.
See @docs/SESSION_LOG.md for session handoff log.
See @docs/decisions/ for design decision records (ADRs).
See @docs/tasks/ for task plans by phase.

## Build / Apply

```bash
home-manager switch --flake '.#at0x0ft@work'        # Apply
home-manager build --flake '.#at0x0ft@work'          # Dry-run
home-manager switch --flake '~/Programming/dotfiles#at0x0ft@work'  # Absolute path
nix flake update                                     # Update flake inputs
```

## Editing Rules

1. **Always edit both language versions together** — Whenever any Markdown file is created or modified, the counterpart file in the other language must be updated in the same operation. English files live at the repo root or under `docs/`; Japanese counterparts live under `docs/ja/` with the `.ja.md` suffix (e.g. `AGENTS.md` ↔ `docs/ja/AGENTS.ja.md`, `docs/tasks/001-foundation.md` ↔ `docs/ja/tasks/001-foundation.ja.md`). Never leave one version out of sync.

## Design Constraints

See `docs/SPEC.md` for design principles and non-negotiable constraints (`docs/ja/SPEC.ja.md` for Japanese).
