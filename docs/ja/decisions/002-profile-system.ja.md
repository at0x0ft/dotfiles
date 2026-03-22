# ADR-002: プロファイル機構: profileDefs ベースの名前付きプロファイル（案 A）

- 日付: 2026-03-03
- ステータス: 採用済み

## 背景

ユーザー向け名前付きプロファイルを導入する際、3つの実装案を検討した:

- **案 A**: `flake.nix` で `profileDefs` を定義してプロファイル名を `{system, env}` にマッピング;
  `homeConfigurations` のキーを `at0x0ft@${profileName}` で生成;
  モジュールスタックに専用の `profiles/${name}.nix` を含める
- **案 B**: system ベースのキー（`at0x0ft@${system}`）を維持しつつプロファイルを `extraSpecialArgs` で渡す;
  system キーと並行して profile 名のエイリアスキーを追加
- **案 C**: `profileDefs` の各エントリに全モジュールリストを直接埋め込む
  （自己記述的だが冗長）

また `home-manager/overrides/` を `home-manager/platforms/` にリネームすることも決定した。OS + CPU arch のプラットフォーム定義であることを名前で直接表現するため。

## 決定

**案 A** を採用する。

- `profileDefs` が `systemEnvironment` マップに代わり、設定生成の唯一の情報源となる
- プロファイル名（`work`, `individual`）がユーザー向け flake 出力キーになる
- `platforms/`（OS+arch）と `profiles/`（ユーザー固有）が `base.nix` の上に積み重なる明確な2層のオーバーライド階層を形成する

## 根拠

案 A は最も明快な分離を提供する。新しいプロファイルの追加は `profileDefs` へのエントリ1件 + `profiles/` にスケルトン `.nix` 1件で完結する。プロファイル名が唯一のユーザー向けキーとなる。

## 却下した代替案

- **案 B** — system キーと profile エイリアスキーの二重構造はどちらを使えばよいか混乱を招く
- **案 C** — `profileDefs` に全モジュールリストを埋め込む形式はプロファイルが増えるにつれ `flake.nix` が冗長で保守しにくくなる

## 結果

- `homeConfigurations` から system 文字列キーがなくなり、全キーがプロファイル名になる
- `systemEnvironment` マップは `profileDefs` 各エントリの `env` フィールドに置き換わる
- 新しいプロファイルの追加 = `profileDefs` へのエントリ1件 + `profiles/` にスケルトン `.nix` 1件
- `overrides/` を `platforms/` にリネーム（Phase 3.1）
- プロファイルごとのモジュールスタック: `home.nix` + `base.nix` + `platforms/${env}.nix` + `profiles/${name}.nix`
