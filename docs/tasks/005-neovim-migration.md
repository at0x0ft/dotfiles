# Phase 5: Neovim Config Migration

## 5.1 Migrate `config/neovim/rc.vim` to Lua

**Goal**: Modernize the Neovim config from VimScript to Lua format, and wire up deployment via `xdg.configFile` in `base.nix`.

- [ ] Create `config/neovim/init.lua` (entry point: `require("options")` and `require("keymaps")`)
  Done when: init.lua loads sub-modules
- [ ] Create `config/neovim/lua/options.lua`
  Done when: all `set ...` are converted to `vim.opt.*`, Neovim-default settings removed, highlights use `vim.api.nvim_set_hl()`
- [ ] Create `config/neovim/lua/keymaps.lua`
  Done when: all `nmap` are converted to `vim.keymap.set()`
- [ ] Add `xdg.configFile."nvim"` entry in `home-manager/base.nix`
  Done when: `config/neovim/` is deployed recursively to `~/.config/nvim/`
- [ ] Remove `config/neovim/rc.vim`
  Done when: file is deleted
- [ ] Verify build
  Done when: `home-manager build` succeeds

**Changed files**: `config/neovim/init.lua` (new), `config/neovim/lua/options.lua` (new), `config/neovim/lua/keymaps.lua` (new), `config/neovim/rc.vim` (delete), `home-manager/base.nix` (edit)

Current progress: Not started.

Last updated: 2026-03-22
