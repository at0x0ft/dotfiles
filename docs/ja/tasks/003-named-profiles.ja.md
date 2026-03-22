# Phase 3: 名前付きプロファイル機構

## 3.1 `overrides/` を `platforms/` にリネーム（改善方針 4.7）

**目的**: ディレクトリの役割を OS + CPU arch のプラットフォーム定義として明確化する。

- [x] `home-manager/overrides/` を `home-manager/platforms/` にリネーム
  完了条件: ディレクトリがリネーム済み
- [x] `flake.nix` 内の参照を更新
  完了条件: overrides/ への参照がなくなる
- [x] ビルド確認
  完了条件: `home-manager build` 成功

**変更ファイル**: `home-manager/platforms/`（`overrides/` からリネーム）, `flake.nix`（編集）

---

## 3.2 `profileDefs` の導入とプロファイルベースの `homeConfigurations` 生成（改善方針 4.7）

**目的**: `homeConfigurations` のキーを system 文字列から名前付きプロファイルへ置き換える。

- [x] `flake.nix` で `profileDefs` を定義
  完了条件: `work = { system = "x86_64-linux"; env = "wsl"; }` が存在する
- [x] `makeHomeConfig` を更新してプロファイル名を受け取り、`profiles/${name}.nix` を含める
  完了条件: プロファイルモジュールがモジュールスタックに含まれる
- [x] キー生成を `"at0x0ft@${profileName}"` に変更
  完了条件: flake 出力キーがプロファイル名を使用する
- [x] ビルド確認
  完了条件: `home-manager build --flake '.#at0x0ft@work'` 成功

**変更ファイル**: `flake.nix`（編集）

---

## 3.3 `profiles/` ディレクトリと初期プロファイルの作成（改善方針 4.7）

**目的**: 初期ユーザープロファイルモジュールを追加する。

- [x] `home-manager/profiles/work.nix` を新規作成（スケルトン）
  完了条件: 最小限のモジュール構造を持つファイルが存在する
- [x] `home-manager/profiles/individual.nix` を新規作成（スケルトン）
  完了条件: 最小限のモジュール構造を持つファイルが存在する
- [x] 全プロファイルのビルド確認
  完了条件: 全プロファイルのビルドが成功する

**変更ファイル**: `home-manager/profiles/work.nix`（新規）, `home-manager/profiles/individual.nix`（新規）

現在の進捗: 全タスク完了。

最終更新: 2026-03-22
