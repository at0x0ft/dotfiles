# 設計決定記録

このプロジェクトの方向性に影響を与えた設計上の決定を記録する。
検討したアプローチを明示的に採用しないと決めた際に記録する。

---

## [2026-03-02] shell-hook: 明示的 opt-in・ロード順序制御のみ

**ステータス**: 採用済み

### 背景

Phase 2（マルチシェル対応）の計画中、`shell-hook` モジュールに `shell`
フィールドと自動シェル種別フィルタリングを追加することを検討した。
具体的には以下を検討した:

- entry submodule に `shell = "zsh" | "bash"` フィールドを追加
- シンボリックリンクの配置先をシェル別サブディレクトリ（`zsh/??-*.d/` 等）に変更
- 拡張子ベースまたはランタイムシェル検出による per-shell `hook.sh` の生成

### 決定

`shell-hook` にシェル種別フィルタリングを追加しない。
モジュールはロード順序制御（フェーズ + 優先度）のみを担当する。

`config/` は人間の管理上の都合でディレクトリ分類しているだけであり、
**自動で読み込まれるものではない**。
ユーザーが `base.nix` に明示的に登録したスクリプトのみが source される。
パッケージをインストールするかどうかはユーザーの裁量であり、
そのパッケージの初期設定スニペットが必要かどうかも同様である。
モジュールがディレクトリ構造や拡張子からロード対象を推論すべきではない。

`hook.sh.tmpl` でのランタイムシェル検出（`$ZSH_VERSION` 等の参照）も不要。
ユーザーが登録するスクリプトを管理する責任を持つため、
各 RC ファイルの hook.sh に対して互換性のあるスクリプトのみを登録することが前提となる。

### 結果

- Phase 2（マルチシェル対応）はタスク計画から削除
- 将来 `.bashrc` を追加する場合は `base.nix` への直接追記のみで、
  `shell-hook.nix` の変更は不要
- `shell-hook.nix` はロード順序制御のみに留まる

---

## [2026-03-03] プロファイル機構: profileDefs ベースの名前付きプロファイル（案 A）

**ステータス**: 採用済み

### 背景

ユーザー向け名前付きプロファイルを導入する際、3つの実装案を検討した:

- **案 A**: `flake.nix` で `profileDefs` を定義してプロファイル名を `{system, env}` にマッピング;
  `homeConfigurations` のキーを `at0x0ft@${profileName}` で生成;
  モジュールスタックに専用の `profiles/${name}.nix` を含める。
- **案 B**: system ベースのキー（`at0x0ft@${system}`）を維持しつつプロファイルを
  `extraSpecialArgs` で渡す; system キーと並行して profile 名のエイリアスキーを追加。
- **案 C**: `profileDefs` の各エントリに全モジュールリストを直接埋め込む
  （自己記述的だが冗長）。

また、`home-manager/overrides/` を `home-manager/platforms/` にリネームすることも決定した。
「上書き」という動詞的なニュアンスよりも、OS + CPU arch のプラットフォーム定義であることを
名前で直接表現するため。

### 決定

案 A を採用する。`profileDefs` が `systemEnvironment` マップに代わり、設定生成の唯一の
情報源となる。プロファイル名（`work`, `individual`）がユーザー向け flake 出力キーになる。
`platforms/`（OS+arch）と `profiles/`（ユーザー固有）のディレクトリが、`base.nix` の上に
積み重なる明確な2層のオーバーライド階層を形成する。

案 B を採却: system キーと profile エイリアスキーの二重構造は、どちらを使えばよいか混乱を招く。
案 C を採却: `profileDefs` に全モジュールリストを埋め込む形式は、プロファイルが増えるにつれ
`flake.nix` が冗長で保守しにくくなる。

### 結果

- `homeConfigurations` から system 文字列キーがなくなり、全キーがプロファイル名になる
- `systemEnvironment` マップは `profileDefs` 各エントリの `env` フィールドに置き換わる
- 新しいプロファイルの追加 = `profileDefs` へのエントリ1件 + `profiles/` にスケルトン `.nix` 1件
- `overrides/` を `platforms/` にリネーム（Phase 3.1）
- プロファイルごとのモジュールスタック: `home.nix` + `base.nix` + `platforms/${env}.nix` + `profiles/${name}.nix`
