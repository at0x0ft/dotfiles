# Phase 4: zinit 統合

## 4.1 zinit モジュール（`home-manager/zinit.nix`）

**目的**: zinit の初期化とプラグインロードを専用モジュールに抽象化し、実装の詳細を `base.nix` から隠蔽する。

- [ ] `home-manager/zinit-init.zsh.tmpl` を新規作成
  完了条件: テンプレートに `source "@zinit_path@/zinit.zsh"` が含まれる
- [ ] `home-manager/zinit.nix` を新規作成
  完了条件: `zsh.zinit.enable`、`zsh.zinit.plugins` を定義し、hook エントリを登録する
- [ ] `home.nix` を更新: `./home-manager/shell-hook.nix` を `./home-manager/zinit.nix` に置き換え
  完了条件: shell-hook が zinit.nix 経由で推移的に引き込まれる
- [ ] `home-manager/base.nix` を更新: `pkgs.zinit` をパッケージリストから削除、zinit hook エントリを削除、`zsh.zinit.enable = true` および `zsh.zinit.plugins = [...]` を追加
  完了条件: base.nix が zinit モジュールのインターフェースのみを使用する
- [ ] `config/zinit/zinit.zsh` は非 Nix 環境向け standalone fallback としてそのまま残す
  完了条件: ファイルが変更されていない
- [ ] ビルド確認
  完了条件: `home-manager build --flake '.#at0x0ft@work'` 成功

**変更ファイル**: `home-manager/zinit.nix`（新規）、`home-manager/zinit-init.zsh.tmpl`（新規）、`home.nix`（編集）、`home-manager/base.nix`（編集）

現在の進捗: 未着手。

最終更新: 2026-03-22
