# CLAUDE.ja.md

## ビルド / 適用

```bash
# 設定を適用
home-manager switch --flake .#at0x0ft

# ドライラン（ビルドのみ、適用なし）
home-manager build --flake .#at0x0ft

# flake 入力の更新（nixpkgs, home-manager）
nix flake update
```

## アーキテクチャ

```
flake.nix          # エントリポイント: nixpkgs + home-manager 入力、unfree 許可リスト
  -> home.nix      # 構成ルート: ユーザー情報、imports、home-manager 有効化
       -> modules/base.nix          # パッケージ、shell-hook エントリ、.zshrc 生成
       -> modules/shell-hooks.nix   # カスタムモジュール: 読み込み順制御のみのフック機構
```

### shell-hooks モジュール

3フェーズと数値優先度による**読み込み順制御のみ**を提供:

- **フェーズ**: `preload.d` -> `main.d` -> `postload.d`
- **優先度**: 数値が小さいほど先に読み込み（10=最初, 50=標準, 90=最後）
- **命名規則**: symlink は `{優先度}-{ファイル名}`（例: `10-zinit.zsh`）
- **ローダー**: 自動生成される `hook.sh` が各フェーズディレクトリを走査し source する
- **接続**: `.zshrc` が `hook.sh` を source する; フックスクリプトは `shell-hook-sources/{zsh,common,bash}/` に配置

## 設計制約（plan.ja.md より）

以下は**絶対遵守の要件** — 詳細は `plan.ja.md` を参照（英語版は `plan.md`）。

1. **`programs.*` を使わない** — home-manager はパッケージインストール（`home.packages`）とファイル配置（`xdg.configFile`, `home.file`）に限定する。ツール設定は `shell-hook-sources/` 内の素のシェルスクリプトであり、`programs.git` や `programs.fzf` 等で生成しない。
2. **ログインシェルを管理しない** — `programs.zsh` を使わず、ログインシェルの選択も管理しない。シェル RC ファイル（`.zshrc`）は `home.file` で配置する。
3. **shell-hooks はシンプルに保つ** — モジュールは読み込み順（フェーズ + 優先度）のみを扱う。依存関係解決やツール固有ロジックは持たない。
4. **未設定のパッケージ/コードを絶対に削除しない** — 一部パッケージ（git, bat, fd, fzf, zsh プラグイン）はここに設定がないが、設定ファイルが別に存在しまだ反映されていないだけである。削除しないこと。
5. **zinit はローダー専任** — zinit は Nix 管理のプラグインを source するのみ。プラグインのバージョン管理やアップデートは行わない。
6. **クロスプラットフォーム目標** — 現状は x86_64-linux のみだが、将来の複数 system（arm64-linux, aarch64-darwin）対応を見据えた設計にすること。
7. **base + override 目標** — 現状はフラット構成だが、将来の環境別パッケージ/設定レイヤリングを見据えた設計にすること。
