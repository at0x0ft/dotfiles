# Phase 5: Neovim 設定の移行

## 5.1 `config/neovim/rc.vim` を Lua 形式へ移行

**目的**: Neovim 設定を VimScript から Lua 形式へ刷新し、`base.nix` の `xdg.configFile` によるデプロイを追加する。

- [ ] `config/neovim/init.lua` を新規作成（エントリポイント）
  完了条件: init.lua がサブモジュールを読み込む
- [ ] `config/neovim/lua/options.lua` を新規作成
  完了条件: 全 `set ...` が `vim.opt.*` に変換、Neovim デフォルト設定削除、ハイライトが `vim.api.nvim_set_hl()` を使用
- [ ] `config/neovim/lua/keymaps.lua` を新規作成
  完了条件: 全 `nmap` が `vim.keymap.set()` に変換
- [ ] `home-manager/base.nix` に `xdg.configFile."nvim"` エントリを追加
  完了条件: `config/neovim/` が `~/.config/nvim/` へ再帰的にデプロイされる
- [ ] `config/neovim/rc.vim` を削除
  完了条件: ファイルが削除されている
- [ ] ビルド確認
  完了条件: `home-manager build` 成功

**変更ファイル**: `config/neovim/init.lua`（新規）, `config/neovim/lua/options.lua`（新規）, `config/neovim/lua/keymaps.lua`（新規）, `config/neovim/rc.vim`（削除）, `home-manager/base.nix`（編集）

現在の進捗: 未着手。

最終更新: 2026-03-22
