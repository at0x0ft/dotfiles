# CLAUDE.ja.md

## ビルド / 適用

```bash
# 設定を適用（dotfiles ディレクトリ内から実行）
home-manager switch --flake '.#at0x0ft@work'

# 絶対パス指定（どこからでも実行可）
home-manager switch --flake '~/Programming/dotfiles#at0x0ft@work'

# ドライラン（ビルドのみ、適用なし; ./result シンボリックリンクが生成される）
home-manager build --flake '.#at0x0ft@work'

# flake 入力の更新（nixpkgs, home-manager）
nix flake update
```

## アーキテクチャ

```
flake.nix          # エントリポイント: 名前付きプロファイル、unfree 許可リスト、プラットフォームモジュール配線
  -> home.nix      # 構成ルート: ユーザー情報、imports、home-manager 有効化
       -> home-manager/base.nix               # ベースパッケージ、shell-hook エントリ、.zshrc 生成
       -> home-manager/shell-hook.nix         # カスタムモジュール: 読み込み順制御のみのフック機構
       -> home-manager/platforms/wsl.nix      # WSL 固有パッケージ（claude-code 等）
       -> home-manager/platforms/darwin.nix   # macOS 固有パッケージ（スケルトン）
       -> home-manager/platforms/linux.nix    # aarch64-linux パッケージ（スケルトン）
```

### ディレクトリの役割

| ディレクトリ | 役割 | Nix 依存 |
|------------|------|----------|
| `home-manager/` | Nix コンポーネント: `.nix` モジュールとビルドテンプレート。パッケージインストール・ファイル配置・読み込み順制御を担う。Nix/home-manager なしでは機能しない。 | 必須 |
| `config/` | ポータブルな dotfiles: 素のシェルスクリプトやアプリ設定ファイル。Nix 非依存 — シンボリックリンク・`stow`・直接 source など任意の手段でデプロイ可能。 | なし |

### shell-hook モジュール

フェーズと数値優先度による**読み込み順制御のみ**を提供:

- **フェーズ**: `shell.hook.phaseOrder` で定義（デフォルト: `preload=0, main=1, postload=2`）; モジュールを変更せず拡張可能
- **フェーズディレクトリ**: `{ゼロ埋め順序}-{フェーズ名}.d` 形式（例: `00-preload.d`, `01-main.d`）; glob のソート順で自動整列
- **優先度**: フェーズ内で数値が小さいほど先に読み込み（10=最初, 50=標準, 90=最後）
- **命名規則**: symlink は `{優先度}-{ファイル名}`（例: `10-zinit.zsh`）
- **ローダー**: `home-manager/hook.sh.tmpl` を `pkgs.replaceVars` で処理して `hook.sh` を生成; 実行時に `??-*.d` グロブでディレクトリを走査
- **接続**: `.zshrc` が `hook.sh` を source する; フックスクリプトは `config/{zsh,zinit,direnv,lsd,delta}/` に配置

## 編集ルール

以下のルールは Claude が行うすべての編集に例外なく適用される。

1. **常に両言語版を同時に編集する** — Markdown ファイルを新規作成または編集する際は、必ず同じ操作で対応する他言語版も更新すること。英語ファイルはリポジトリルートまたは `docs/` 以下に配置され、日本語版は `docs/ja/` 以下に `.ja.md` サフィックスで対応する（例: `CLAUDE.md` ↔ `docs/ja/CLAUDE.ja.md`、`tasks.md` ↔ `docs/ja/tasks.ja.md`）。片方だけ更新して不整合な状態にしてはならない。

## 設計制約

設計原則と絶対遵守の制約については `docs/ja/SPEC.ja.md` を参照（英語版は `docs/SPEC.md`）。
