# タスク計画

plan.ja.md セクション4（改善方針）に基づくタスク分解。
依存関係を考慮した実施順序で記載する。

---

## Phase 1: 基盤整理（他タスクの前提）

### 1.1 home.nix の分割（改善方針 4.3）

**目的**: home.nix の責務を最小化し、後続の環境別オーバーライド（4.2）やマルチシェル対応（4.4）の土台を作る。

**現状**: home.nix がパッケージ定義・フックエントリ・.zshrc 生成を一手に担っている。

**タスク**:

- [x] `modules/base.nix` を新規作成
  - `home.packages` のリストを home.nix から移動
  - `shell.hook.entries` のリストを home.nix から移動
  - `.zshrc` 生成ロジックを home.nix から移動
- [x] home.nix を最小構成に整理
  - `home.username` / `home.homeDirectory` / `home.stateVersion`
  - `imports = [ ./modules/shell-hook.nix ./modules/base.nix ]`
  - `programs.home-manager.enable = true`
- [x] `home-manager build --flake .#at0x0ft` で差分なしビルドを確認（既存動作の維持）

**変更ファイル**: `home.nix`（編集）, `modules/base.nix`（新規）

**注意**: `pkgs-unfree` の引数渡しが base.nix でも使えるよう `extraSpecialArgs` の経路を維持すること。

---

### 1.2 shell-hook モジュールの整理（改善方針 4.5）

**目的**: TODO コメントの解消と `baseDir` オプションの一貫性改善。

**現状**: `# TODO: refactor as config.xdg.configFile.(...).target;` が残っている。

**タスク**:

- [x] `baseDir` オプションの用途を `xdg.configFile` の target パスとして明確化
  - 現状すでに `xdg.configFile` 経由で配置しているため、TODO コメントの趣旨を確認し整理
- [x] TODO コメントを解消（リファクタリングまたはコメント削除）
- [x] フェーズ/優先度の制御ロジックには手を加えない（要件3: シンプルさ維持）
- [x] ビルド確認

**変更ファイル**: `modules/shell-hook.nix`（編集）

---

## Phase 2: クロスプラットフォーム・環境別対応

### 2.1 flake.nix の複数 system 対応（改善方針 4.1）

**目的**: x86_64-linux 以外の system（aarch64-linux, aarch64-darwin）でもビルド可能にする。

**現状**: `system = "x86_64-linux"` がハードコードされている。

**タスク**:

- [ ] `supportedSystems` リストを定義
  - `[ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]`
- [ ] `nixpkgs.lib.genAttrs` 等で system ごとに `homeConfigurations` を生成
  - 命名規則: `"at0x0ft@${system}"` または `"at0x0ft"` を system 引数で切り替え
- [ ] `pkgs-unfree` の生成を各 system で動的に行う（4.6 と連動）
- [ ] `extraSpecialArgs` に `system` 情報を渡し、モジュール内で条件分岐可能にする
- [ ] 既存の x86_64-linux 環境でのビルド確認（`home-manager build --flake .#at0x0ft@x86_64-linux`）

**変更ファイル**: `flake.nix`（編集）

**注意**: `shell-hook-sources/` は変更不要（既にポータブル）。

---

### 2.2 環境別オーバーライド機構の導入（改善方針 4.2）

**目的**: base パッケージセットの上に環境固有の差分を重ねる層構造を実現する。

**現状**: 全パッケージがフラットに列挙されており、環境別の切り替え機構がない。

**タスク**:

- [ ] `modules/overrides/` ディレクトリを作成
- [ ] `modules/overrides/wsl.nix` を新規作成
  - WSL 固有の追加パッケージ（例: `claude-code` は WSL 環境のみ等）
  - WSL 固有のフックエントリ（あれば）
- [ ] `modules/overrides/darwin.nix` を新規作成（スケルトン）
  - macOS 固有の追加パッケージ
  - macOS 固有のフックエントリ
- [ ] `flake.nix` で system / 環境に応じて適切な override モジュールを `imports` に追加
  - `isDarwin` / `isLinux` 等のフラグを `extraSpecialArgs` で渡す
- [ ] ビルド確認

**変更ファイル**: `flake.nix`（編集）, `modules/overrides/wsl.nix`（新規）, `modules/overrides/darwin.nix`（新規）

---

### 2.3 unfree パッケージの扱い整理（改善方針 4.6）

**目的**: unfree 許可リストをオーバーライド可能にする。

**現状**: `flake.nix` で `claude-code` のみ許可。

**タスク**:

- [ ] unfree 許可リストを override モジュールから注入可能にする
  - base: 空リスト
  - override（例: `wsl.nix`）: `[ "claude-code" ]` 等
- [ ] `pkgs-unfree` の生成を許可リストと system の両方に基づいて動的に行う
- [ ] ビルド確認

**変更ファイル**: `flake.nix`（編集）, `modules/overrides/wsl.nix`（編集）

**注意**: 3.1 および 3.2 と密接に連動するため、同時に実施するのが望ましい。

---

## 依存関係まとめ

```
Phase 1 (基盤整理)
  1.1 home.nix の分割 ─────────┐
  1.2 shell-hook の整理 ──────┤
                               v
Phase 2 (クロスプラットフォーム)
  2.1 複数 system 対応 ────────┤ (1.1 に依存)
  2.2 環境別オーバーライド ────┤ (1.1, 2.1 に依存)
  2.3 unfree 整理 ─────────────┘ (2.1, 2.2 に依存)
```

## 共通の制約事項

全タスクを通じて以下を遵守すること:

- **`programs.*` を使わない**（`programs.home-manager.enable` のみ例外）
- **ログインシェルを管理しない**
- **未設定のパッケージ/コードを削除しない**
- **shell-hook モジュールをシンプルに保つ**（読み込み順制御のみ）
- 各タスク完了時に `home-manager build` で既存動作の維持を確認する
