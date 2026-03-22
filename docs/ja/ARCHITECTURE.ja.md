# アーキテクチャ

## モジュール構成

```
flake.nix          # エントリポイント: 名前付きプロファイル、unfree 許可リスト、プラットフォームモジュール配線
  -> home.nix      # 構成ルート: ユーザー情報、imports、home-manager 有効化
       -> home-manager/base.nix               # ベースパッケージ、shell-hook エントリ、.zshrc 生成
       -> home-manager/shell-hook.nix         # カスタムモジュール: 読み込み順制御のみのフック機構
       -> home-manager/platforms/wsl.nix      # WSL 固有パッケージ（claude-code 等）
       -> home-manager/platforms/darwin.nix   # macOS 固有パッケージ（スケルトン）
       -> home-manager/platforms/linux.nix    # aarch64-linux パッケージ（スケルトン）
```

## ディレクトリの役割

| ディレクトリ | 役割 | Nix 依存 |
|------------|------|----------|
| `home-manager/` | Nix コンポーネント: `.nix` モジュールとビルドテンプレート。パッケージインストール・ファイル配置・読み込み順制御を担う。Nix/home-manager なしでは機能しない。 | 必須 |
| `config/` | ポータブルな dotfiles: 素のシェルスクリプトやアプリ設定ファイル。Nix 非依存 — シンボリックリンク・`stow`・直接 source など任意の手段でデプロイ可能。 | なし |

## shell-hook モジュール

フェーズと数値優先度による**読み込み順制御のみ**を提供:

- **フェーズ**: `shell.hook.phaseOrder` で定義（デフォルト: `preload=0, main=1, postload=2`）; モジュールを変更せず拡張可能
- **フェーズディレクトリ**: `{ゼロ埋め順序}-{フェーズ名}.d` 形式（例: `00-preload.d`, `01-main.d`）; glob のソート順で自動整列
- **優先度**: フェーズ内で数値が小さいほど先に読み込み（10=最初, 50=標準, 90=最後）
- **命名規則**: symlink は `{優先度}-{ファイル名}`（例: `10-zinit.zsh`）
- **ローダー**: `home-manager/hook.sh.tmpl` を `pkgs.replaceVars` で処理して `hook.sh` を生成; 実行時に `??-*.d` グロブでディレクトリを走査
- **接続**: `.zshrc` が `hook.sh` を source する; フックスクリプトは `config/{zsh,zinit,direnv,lsd,delta}/` に配置

## 技術スタック

| コンポーネント | 技術 |
|------------|------|
| パッケージ管理 | Nix flakes + home-manager |
| シェル | Zsh（ログインシェルとしては管理しない） |
| プラグインマネージャ | zinit |
| 設定デプロイ | `xdg.configFile`（`~/.config/` 向け）、`home.file`（`~/` 向け） |
