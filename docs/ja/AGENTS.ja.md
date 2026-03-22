# AGENTS.ja.md

Nix + home-manager ベースのクロスプラットフォーム dotfiles。読み込み順制御付きシェルフック機構。

## 参照ドキュメント

要件と設計原則は @docs/ja/SPEC.ja.md を参照。
モジュール構成とディレクトリの役割は @docs/ja/ARCHITECTURE.ja.md を参照。
セッション引き継ぎログは @docs/ja/SESSION_LOG.ja.md を参照。
設計決定記録（ADR）は @docs/ja/decisions/ を参照。
フェーズ別タスク計画は @docs/ja/tasks/ を参照。

## ビルド / 適用

```bash
home-manager switch --flake '.#at0x0ft@work'        # 適用
home-manager build --flake '.#at0x0ft@work'          # ドライラン
home-manager switch --flake '~/Programming/dotfiles#at0x0ft@work'  # 絶対パス
nix flake update                                     # flake 入力の更新
```

## 編集ルール

1. **常に両言語版を同時に編集する** — Markdown ファイルを新規作成または編集する際は、必ず同じ操作で対応する他言語版も更新すること。英語ファイルはリポジトリルートまたは `docs/` 以下に配置され、日本語版は `docs/ja/` 以下に `.ja.md` サフィックスで対応する（例: `AGENTS.md` ↔ `docs/ja/AGENTS.ja.md`、`docs/tasks/001-foundation.md` ↔ `docs/ja/tasks/001-foundation.ja.md`）。片方だけ更新して不整合な状態にしてはならない。

## 設計制約

設計原則と絶対遵守の制約については `docs/ja/SPEC.ja.md` を参照（英語版は `docs/SPEC.md`）。
