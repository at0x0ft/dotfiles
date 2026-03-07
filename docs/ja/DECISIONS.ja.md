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

---

## [2026-03-08] 設定ファイルのデプロイ: `xdg.configFile` を標準機構として採用

**ステータス**: 採用済み

### 背景

Neovim 設定を Lua 形式へ移行する際、`config/` 配下のアプリ設定ファイルを
home-manager でどのように配置するかという問題が生じた。調査した選択肢は以下の通り:

- **`programs.*` モジュール**: ツール固有の高レベル抽象。プロジェクトの設計制約
  （CLAUDE.md: 「`programs.*` を使わない」）により既に却下済み。
- **`home.file`**: `~/`（ホームディレクトリ直下）にファイルを配置する。
  `.zshrc` のようなファイルには適切だが、`~/.config/` を読む XDG 準拠アプリには不適切。
- **`xdg.configFile`**: `$XDG_CONFIG_HOME`（`~/.config/`）にファイルを配置する。
  Nix ストアへのシンボリックリンクを生成する。`programs.*` を使わない場合の
  XDG 準拠アプリに対する標準的な home-manager の機構。
- **`mkOutOfStoreSymlink`**: ホットリロード可能なインピュアモード。
  再現性を犠牲にして高速な反復を実現する。このプロジェクトの純粋なストアベース
  アプローチとは一貫しない。

コミュニティの慣習でも、`programs.*` を使わない場合に `xdg.configFile` が
XDG 準拠アプリに対するイディオマティックな選択であることが確認されている。

### 決定

`~/.config/` を対象とするアプリ設定ファイルのデプロイには `xdg.configFile` を
標準機構として使用する。`home.file` は `~/` 直下に置くファイル（`.zshrc` 等）
専用とする。`mkOutOfStoreSymlink` は使用しない。

### 結果

- 新しいアプリ設定のデプロイ（Neovim、将来のツール等）はすべて `base.nix` または
  platform/profile モジュールの `xdg.configFile` を通じて行う
- `home.file` はホームルートのファイル（`.zshrc` 等）専用
- `config/` ディレクトリはポータブルかつ Nix 非依存のまま維持し、
  デプロイの配線は `base.nix` の `xdg.configFile` で行う

---

## [2026-03-08] zinit モジュール: 名前空間・アーキテクチャ・プラグイン拡張性

**ステータス**: 採用済み

### 背景

zinit の Nix モジュール設計（Phase 4.1）において、以下の複数の論点があった。

**名前空間**: `shell.hook` が既に存在するため `shell.zinit` が最初の候補として挙がった。
フラットな `zinit.enable` も検討された。

**アーキテクチャ**: Nix ストアパスの埋め込み方法として 2 つのアプローチを比較した:
- `base.nix` に直接 `pkgs.writeText` をインライン記述する方法
- `shell-hook.nix` + `hook.sh.tmpl` のパターンを踏襲し、専用モジュール（`zinit.nix`）とテンプレートファイルで構成する方法

**プラグインロードの拡張性**: zinit は複数のロード動詞（`snippet`, `light`, `load`）と
任意の ice modifier をサポートする。単純な `plugins = [package]` リストではこれらを表現できない。

**モジュール依存関係**: `zinit.nix` は `shell.hook.entries` を使用するが、これは `shell-hook.nix`
が定義する。明示的な宣言がなければ依存は暗黙的となり、単体利用時に問題になる。

### 決定

**名前空間 → `zsh.zinit`**: zinit は zsh 固有のツールであり、シェル非依存ではないため
`shell.zinit` を却下した。`shell.hook` はシェル非依存のロード順制御機構として適切だが、
zinit は zsh 以外に意味をなさない。フラットな `zinit.enable` より `zsh.zinit` を選んだ理由は、
他の zsh 固有プラグインも同じ構造的課題（インストールされているがロードされていない）を抱えており、
`zsh.*` 名前空間がそれらの自然な置き場になるため。

**モジュールアーキテクチャ → テンプレート + モジュール（shell-hook パターンの踏襲）**:
`pkgs.writeText` を `base.nix` に直接埋め込む方法では、Nix ストアパスや zinit コマンド構造という
実装の詳細が構成層に露出してしまう。代わりに `zinit.nix` がこれをカプセル化し、
init スクリプトは `pkgs.replaceVars` で処理する `zinit-init.zsh.tmpl` テンプレートを使用し、
動的なプラグインリストは Nix 文字列補間で `pkgs.writeText` により生成する。
2 つのスクリプトは別々の hook エントリとして登録される（priority 10: init、priority 20: plugins）。

**プラグインオプション → `verb`・`path`・`ices` を持つサブモジュール**: パッケージのリストだけでは
異なるロード動詞や ice modifier を表現できない。サブモジュールは zinit のコマンド構造に直接対応する:
`zi ice <ices...>` に続けて `zi <verb> <path>`。現時点のユースケースをすべてカバーしつつ、
モジュールを変更せずに新しい ice を追加できる。

**モジュール依存関係 → 明示的な `imports`**: `zinit.nix` が `imports = [ ./shell-hook.nix ]`
を宣言することで依存を自己完結させる。Nix モジュールシステムは同じ import パスを重複排除するため、
呼び出し側が `shell-hook.nix` を import していても安全。結果として `home.nix` は `zinit.nix`
のみを import すればよい。

### 結果

- `base.nix` では `zsh.zinit.enable = true` と `zsh.zinit.plugins = [...]` を宣言するだけ。Nix ストアパスや zinit コマンドは現れない
- `home.nix` は `zinit.nix` のみを import し、`shell-hook.nix` は推移的に引き込まれる
- `config/zinit/zinit.zsh` は非 Nix 環境向け standalone fallback として変更なく残す
- `zsh.*` 名前空間が確立され、将来の zsh 固有モジュール（プラグインごとのモジュール等）の置き場になる
