# Global Settings

Communicate in English. Write commit messages in English using Conventional Commits format.

## Development Process

For new projects, create the following documents under docs/ in order before writing any code.
For existing projects, prepare these documents before implementation if docs/ is not yet set up.

### 1. docs/SPEC.md (What to build)

Define: purpose (1-2 sentences), use cases (bullet list), out of scope (what NOT to build), non-functional requirements, and success criteria.

### 2. docs/ARCHITECTURE.md (How to build it)

Describe: tech stack (table format), directory structure (tree format), design principles (3-5 items), and data model (type definitions).

### 3. docs/decisions/ (Why we decided that way)

Create one file per decision as `NNN-title.md`. Use `##` headings per section — not inline `- Key: value` on a single line. Long prose must be broken into bullet lists under each heading.

```
# ADR-NNN: Title
- Date:
- Status: Accepted / Rejected / Pending / Deprecated
## Context        — Background and options considered (bullet list)
## Decision       — What was chosen and key points (bullet list)
## Rationale      — Why it was chosen (1-2 sentences or bullets)
## Rejected Alternatives — Each alternative as `**Name** — reason` bullets
## Consequences   — Resulting constraints and impacts (bullet list)
```
Filename examples: `001-state-management.md`, `002-data-persistence.md`

### 4. docs/tasks/ (What to do and in what order)

Create one file per phase as `NNN-phase-name.md`. Each task uses `- [ ]` checkbox format with a one-line "Done when:" immediately below it. Include "Current progress" and "Last updated" at the end of each file.
Filename examples: `001-setup.md`, `002-core-features.md`, `003-polish.md`

### 5. docs/sessions/ (Handoff between sessions)

Create one file per session as `YYYY-MM-DD-NNNN.md` (e.g. `2026-03-22-0001.md`, `2026-03-22-0002.md`). Each entry includes: What was done / Remaining issues / Next steps / Notes and observations. These files are gitignored (local development history only), but the directory structure is tracked. **Exception: Session logs are English-only — no Japanese counterparts.**

## Project Root CLAUDE.md

Once the above documents are in place, create a CLAUDE.md at the project root.

Include:
- Project summary (1 line)
- Reference links in `See @docs/SPEC.md` format
- Build, test, and lint command list
- Code rules (project-specific)

Do not include: detailed design rationale, decision history, or task lists (all delegated to docs/).
Target: under 50 lines.

## Session Rules

- On start: review the latest session file in docs/sessions/ (highest NNNN for today) and the current phase file in docs/tasks/
- Before ending: update checkboxes in the current tasks file and create a new session file in docs/sessions/ with next sequence number
- On design decisions: create a new ADR file in docs/decisions/
- Before `/compact`: also update the current session file in docs/sessions/
