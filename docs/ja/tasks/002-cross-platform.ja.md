# Phase 2: クロスプラットフォーム・環境別対応

## 2.1 flake.nix の複数 system 対応（改善方針 4.1）

**目的**: x86_64-linux 以外の system（aarch64-linux, aarch64-darwin）でもビルド可能にする。

- [x] `supportedSystems` リストを定義
  完了条件: `[ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]` が定義済み
- [x] `builtins.listToAttrs + map` で system ごとに `homeConfigurations` を生成
  完了条件: homeConfigurations が動的に生成される
- [x] `pkgs-unfree` の生成を各 system で動的に行う
  完了条件: 各 system が独自の pkgs-unfree を持つ
- [x] `isDarwin` / `isLinux` フラグを `extraSpecialArgs` で渡す
  完了条件: モジュール内でプラットフォーム分岐可能
- [x] 既存の x86_64-linux 環境でのビルド確認
  完了条件: `home-manager build --flake '.#at0x0ft@x86_64-linux'` 成功

**変更ファイル**: `flake.nix`（編集）

---

## 2.2 環境別オーバーライド機構の導入（改善方針 4.2）

**目的**: base パッケージセットの上に環境固有の差分を重ねる層構造を実現する。

- [x] `home-manager/overrides/` ディレクトリを作成
  完了条件: ディレクトリが存在する
- [x] `home-manager/overrides/wsl.nix` を新規作成（WSL 固有パッケージ）
  完了条件: claude-code が wsl.nix に含まれる
- [x] `home-manager/overrides/darwin.nix` を新規作成（スケルトン）
  完了条件: スケルトンファイルが存在する
- [x] `home-manager/overrides/linux.nix` を新規作成（スケルトン）
  完了条件: スケルトンファイルが存在する
- [x] `flake.nix` で system / 環境に応じた override モジュールを配線
  完了条件: override モジュールが modules リストに含まれる
- [x] ビルド確認
  完了条件: `home-manager build` 成功

**変更ファイル**: `flake.nix`（編集）, `home-manager/overrides/*.nix`（新規）

---

## 2.3 unfree パッケージの扱い整理（改善方針 4.6）

**目的**: unfree 許可リストをオーバーライド可能にする。

- [x] unfree 許可リストを環境別に定義可能にする
  完了条件: `flake.nix` 内の `unfreeAllowlists` attr set が存在する
- [x] `pkgs-unfree` の生成を許可リストと system の両方に基づいて動的に行う
  完了条件: pkgs-unfree がマージされた許可リストを使用する
- [x] ビルド確認
  完了条件: `home-manager build` 成功

**変更ファイル**: `flake.nix`（編集）, `home-manager/overrides/wsl.nix`（新規）

現在の進捗: 全タスク完了。

最終更新: 2026-03-22
