# Phase 3: Named Profile System

## 3.1 Rename `overrides/` to `platforms/` (Policy 4.7)

**Goal**: Clarify the directory's role as OS + CPU arch platform definitions.

- [x] Rename `home-manager/overrides/` to `home-manager/platforms/`
  Done when: directory is renamed
- [x] Update all references in `flake.nix`
  Done when: no references to overrides/ remain
- [x] Verify build
  Done when: `home-manager build` succeeds

**Changed files**: `home-manager/platforms/` (rename from `overrides/`), `flake.nix` (edit)

---

## 3.2 Introduce `profileDefs` and Profile-based `homeConfigurations` (Policy 4.7)

**Goal**: Replace system-string keys with named user profiles.

- [x] Define `profileDefs` in `flake.nix`
  Done when: `work = { system = "x86_64-linux"; env = "wsl"; }` exists
- [x] Update `makeHomeConfig` to accept profile name and include `profiles/${name}.nix`
  Done when: profile module is in the module stack
- [x] Change key generation to `"at0x0ft@${profileName}"`
  Done when: flake output keys use profile names
- [x] Verify build: `home-manager build --flake '.#at0x0ft@work'`
  Done when: build succeeds with new key format

**Changed files**: `flake.nix` (edit)

---

## 3.3 Create `profiles/` Directory with Initial Profiles (Policy 4.7)

**Goal**: Add initial user profile modules.

- [x] Create `home-manager/profiles/work.nix` (skeleton)
  Done when: file exists with minimal module structure
- [x] Create `home-manager/profiles/individual.nix` (skeleton)
  Done when: file exists with minimal module structure
- [x] Verify build for all profiles
  Done when: all profile builds succeed

**Changed files**: `home-manager/profiles/work.nix` (new), `home-manager/profiles/individual.nix` (new)

Current progress: All tasks complete.

Last updated: 2026-03-22
