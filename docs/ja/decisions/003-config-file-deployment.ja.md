# ADR-003: 設定ファイルのデプロイ: xdg.configFile を標準機構として採用

- 日付: 2026-03-08
- ステータス: 採用済み

## 背景

Neovim 設定を Lua 形式へ移行する際、`config/` 配下のアプリ設定ファイルを home-manager でどのように配置するかという問題が生じた。調査した選択肢:

- **`programs.*` モジュール** — ツール固有の高レベル抽象。
  プロジェクトの設計制約により既に却下済み。
- **`home.file`** — `~/`（ホームディレクトリ直下）にファイルを配置。
  `.zshrc` には適切だが、`~/.config/` を読む XDG 準拠アプリには不適切。
- **`xdg.configFile`** — `$XDG_CONFIG_HOME`（`~/.config/`）にファイルを配置。
  Nix ストアへのシンボリックリンクを生成。`programs.*` を使わない場合の標準的な home-manager の機構。
- **`mkOutOfStoreSymlink`** — ホットリロード可能なインピュアモード。
  再現性を犠牲にして高速な反復を実現。本プロジェクトの純粋なストアベースアプローチとは一貫しない。

コミュニティの慣習でも、`programs.*` を使わない場合に `xdg.configFile` がイディオマティックな選択であることが確認されている。

## 決定

- `~/.config/` を対象とするアプリ設定ファイルのデプロイには `xdg.configFile` を標準機構として使用する
- `home.file` は `~/` 直下に置くファイル専用とする
- `mkOutOfStoreSymlink` は使用しない

## 根拠

`xdg.configFile` は XDG 準拠アプリに対する home-manager のイディオマティックな選択であり、プロジェクトの純粋なストアベースアプローチと一貫する。ツール固有の `programs.*` 抽象を回避できる。

## 却下した代替案

- **`programs.*` モジュール** — プロジェクトの設計制約に違反
- **`home.file`** — `~/.config/` パスに対して意味的に不適切
- **`mkOutOfStoreSymlink`** — 再現性を犠牲にする。プロジェクトのアプローチと一貫しない

## 結果

- 新しいアプリ設定のデプロイはすべて `base.nix` または platform/profile モジュールの `xdg.configFile` を通じて行う
- `home.file` はホームルートのファイル（`.zshrc` 等）専用
- `config/` ディレクトリはポータブルかつ Nix 非依存のまま維持し、デプロイの配線は `base.nix` の `xdg.configFile` で行う
