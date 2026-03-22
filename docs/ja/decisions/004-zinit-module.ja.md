# ADR-004: zinit モジュール: 名前空間・アーキテクチャ・プラグイン拡張性

- 日付: 2026-03-08
- ステータス: 採用済み

## 背景

zinit の Nix モジュール設計（Phase 4.1）において、複数の論点があった:

- **名前空間**: 候補は `shell.zinit`、フラットな `zinit.enable`、`zsh.zinit`
- **アーキテクチャ**: `base.nix` にインラインで `pkgs.writeText` を記述する方法 vs. shell-hook パターンを踏襲した専用モジュール + テンプレート
- **プラグインロード**: 複数のロード動詞（`snippet`, `light`, `load`）と任意の ice modifier のサポートが必要 — 単純な `plugins = [package]` リストでは表現不可能
- **モジュール依存関係**: `zinit.nix` は `shell-hook.nix` の `shell.hook.entries` を使用するため、明示的な宣言が必要

## 決定

1. **名前空間 → `zsh.zinit`**
   - zinit は zsh 固有であり、シェル非依存ではない
   - `zsh.*` 名前空間が zsh 固有プラグインの自然な置き場になる
2. **アーキテクチャ → テンプレート + モジュール**（shell-hook パターンの踏襲）
   - `zinit.nix` が実装詳細をカプセル化
   - `zinit-init.zsh.tmpl` を `pkgs.replaceVars` で処理（init スクリプト）
   - 動的プラグインリストを `pkgs.writeText` + Nix 文字列補間で生成
   - hook エントリは priority 10（init）と priority 20（plugins）の2件
3. **プラグインオプション → `verb`・`path`・`ices` を持つサブモジュール**
   - zinit のコマンド構造に直接対応: `zi ice <ices...>` → `zi <verb> <path>`
   - 現行ユースケースをすべてカバーし、モジュール変更なしで拡張可能
4. **モジュール依存関係 → 明示的な `imports`**
   - `zinit.nix` で `imports = [ ./shell-hook.nix ]` を宣言
   - Nix モジュールシステムは同一 import パスを重複排除するため、呼び出し側が `shell-hook.nix` を import していても安全

## 根拠

- `zsh.zinit` は正しくモジュールのスコープを zsh に限定する
- テンプレート + モジュールパターンは `base.nix` を実装詳細から解放する
- サブモジュールは現行ユースケースをすべてカバーしつつモジュール変更なしで拡張可能

## 却下した代替案

- **`shell.zinit`** — zinit は zsh 以外に意味をなさない
- **フラットな `zinit.enable`** — 将来の zsh 固有モジュールの名前空間がない
- **`base.nix` にインライン `pkgs.writeText`** — 構成層に実装詳細が露出する
- **単純な `plugins = [package]` リスト** — ロード動詞や ice modifier を表現できない

## 結果

- `base.nix` では `zsh.zinit.enable = true` と `zsh.zinit.plugins = [...]` を宣言するだけ。Nix ストアパスや zinit コマンドは現れない
- `home.nix` は `zinit.nix` のみを import し、`shell-hook.nix` は推移的に引き込まれる
- `config/zinit/zinit.zsh` は非 Nix 環境向け standalone fallback として変更なく残す
- `zsh.*` 名前空間が確立され、将来の zsh 固有モジュールの置き場になる
