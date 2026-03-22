# Phase 6: バックログ

## 6.1 再利用可能なモジュールの別リポジトリへの切り出し

**目的**: `shell-hook` および `zinit` モジュールをスタンドアロンの flake として公開し、他ユーザーが再利用できるようにする。

**背景**: これらのモジュール（shell-hook、zinit）はこの dotfiles リポジトリ固有ではなく汎用的なものである。切り出すことで再利用性が向上し、他ユーザーが flake input として利用できるようになる。

- [ ] 新リポジトリを作成（例: `nix-zsh-modules` など）
  完了条件: 初期構造を持つリポジトリが存在する
- [ ] `home-manager/shell-hook.nix` + `hook.sh.tmpl` を移行
  完了条件: ファイルが新リポジトリに移動済み
- [ ] `home-manager/zinit.nix` + `zinit-init.zsh.tmpl` を移行
  完了条件: ファイルが新リポジトリに移動済み
- [ ] flake outputs として home-manager モジュールを公開
  完了条件: flake.nix がモジュールをエクスポートする
- [ ] この dotfiles リポジトリを新 flake の input として利用するよう更新
  完了条件: dotfiles の flake.nix が外部モジュールを使用する
- [ ] 最小限のドキュメント / README を作成
  完了条件: README が使い方を説明している

**注記**: zinit モジュール（4.1）が安定してモジュールインターフェースが確定した後に実施する。

現在の進捗: 未着手。

最終更新: 2026-03-22
