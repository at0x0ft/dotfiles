# Phase 1: 基盤整理（他タスクの前提）

## 1.1 home.nix の分割（改善方針 4.3）

**目的**: home.nix の責務を最小化し、後続の環境別オーバーライド（4.2）やマルチシェル対応（4.4）の土台を作る。

- [x] `home-manager/base.nix` を新規作成
  完了条件: `home.packages`、`shell.hook.entries`、`.zshrc` 生成が base.nix に移動済み
- [x] home.nix を最小構成に整理
  完了条件: home.nix にはユーザー情報、imports、`programs.home-manager.enable` のみ
- [x] `home-manager build --flake .#at0x0ft` で差分なしビルドを確認
  完了条件: 同一出力でビルド成功

**変更ファイル**: `home.nix`（編集）, `home-manager/base.nix`（新規）

---

## 1.2 shell-hook モジュールの整理（改善方針 4.5）

**目的**: TODO コメントの解消と `baseDir` オプションの一貫性改善。

- [x] `baseDir` オプションの用途を `xdg.configFile` の target パスとして明確化
  完了条件: baseDir のセマンティクスが文書化されているか自明
- [x] TODO コメントを解消（リファクタリングまたはコメント削除）
  完了条件: shell-hook.nix に TODO コメントなし
- [x] ビルド確認
  完了条件: `home-manager build` 成功

**変更ファイル**: `home-manager/shell-hook.nix`（編集）

現在の進捗: 全タスク完了。

最終更新: 2026-03-22
