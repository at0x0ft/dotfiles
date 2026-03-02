# home-manager 構成 要件定義書

## 1. 要件定義

1. Linux (x86_64 & arm64; WSL も含む) や Darwin へ同じツールをインストールする際に、大部分の共通化された宣言的コードで管理すること
2. git や fzf 等の各種ツールの設定ファイルは home-manager と密結合にせずに lean な作りを守り、従来のよくある shell-script 製の dotfiles でも管理可能な形式を保つこと
3. ツール間の依存関係を解決するような高度な共通モジュールを作り込むことはせず、読み込み順制御のみサポートするような作りに留めること
4. ログインシェルは例外的にここでは管理しない
    1. OS 側のデフォルトログインシェルとの兼ね合いもあって複雑で、home-manager 側から OS の具体に依存してしまうため
    2. 現状では zsh を前提としているが、 bash や fish 等でも問題なく動くような作りにはしておく
5. シェルのプラグインマネージャー (例えば zinit など) はプラグインの読み込みのためだけに利用し、プラグインのアップデートやバージョン管理は home-manager 側で全て厳密に管理すること
6. 環境によって含めたいアプリケーションに差分があるため、base と override のような形でインストールできるアプリケーションを柔軟に切り替えられるような機構を担保すること
7. 設定がなされていないコードがいくつかあるが、これは別に設定ファイルが存在してまだ反映されていないだけであるため、ここでは絶対に削除しないこと

---

## 2. 現状分析

### 2.1 プロジェクト概要

Nix Flakes + Home Manager による、ユーザー `at0x0ft` のホームディレクトリ環境の宣言的管理。
現在は WSL2 (x86_64-linux) 上で動作し、Zsh を主シェルとした開発環境を構築している。

### 2.2 ディレクトリ構成

```
~/.config/home-manager/
├── flake.nix                        # エントリポイント (Nix Flakes)
├── flake.lock                       # 依存バージョンのロックファイル
├── home.nix                         # メイン Home Manager 設定
├── home-manager/
│   ├── shell-hook.nix              # カスタムモジュール: シェルフック機構
│   ├── base.nix                    # パッケージ、shell-hook エントリ、.zshrc 生成
│   └── hook.sh.tmpl                # フックローダーテンプレート (Nix コンポーネント)
└── config/                          # ポータブルな設定ファイル群 (Nix 非依存)
    ├── zsh/                         # zsh シェル設定
    │   ├── envvar.zsh               # 環境変数設定
    │   ├── option.zsh               # Zsh オプション (history, directory)
    │   └── keybind.zsh              # キーバインド設定
    ├── zinit/                       # zinit プラグインマネージャ
    │   └── zinit.zsh                # 初期化スクリプト
    ├── direnv/                      # direnv シェル統合
    │   ├── hook.zsh                 # direnv フック (Zsh 用)
    │   └── hook.bash                # direnv フック (Bash 用)
    ├── lsd/                         # lsd (ls 代替)
    │   └── aliases.sh               # lsd エイリアス
    └── delta/                       # delta (diff ビューア)
        └── functions.sh             # delta を使ったシェル関数
└── shell-hook/                     # Home Manager が生成する出力 (symlink 群)
    ├── hook.sh                      # 自動生成されるフックローダー
    ├── main.d/
    └── postload.d/
```

### 2.3 依存関係

| 入力 | ソース | 用途 |
|------|--------|------|
| nixpkgs | `github:nixos/nixpkgs/nixos-unstable` | パッケージ提供 |
| home-manager | `github:nix-community/home-manager` | ホーム環境管理 (nixpkgs に follows) |

### 2.4 インストール済みパッケージ (14個)

| パッケージ | 分類 | 設定状況 |
|-----------|------|----------|
| `claude-code` | AI ツール | unfree (専用 pkgs-unfree 経由) |
| `neovim` | エディタ | EDITOR として `config/zsh/envvar.zsh` で参照 |
| `direnv` | 環境切替 | `config/direnv/hook.zsh` / `hook.bash` でフック |
| `git` | VCS | パッケージのみ (設定は別途管理、要件7) |
| `lsd` | ls 代替 | `config/lsd/aliases.sh` でエイリアス設定 |
| `bat` | cat 代替 | パッケージのみ (設定は別途管理、要件7) |
| `fd` | find 代替 | パッケージのみ (設定は別途管理、要件7) |
| `delta` | diff ビューア | `config/delta/functions.sh` で関数定義 |
| `fzf` | ファジーファインダー | パッケージのみ (設定は別途管理、要件7) |
| `zinit` | Zsh プラグインマネージャ | `config/zinit/zinit.zsh` で初期化 (要件5: ローダー専任) |
| `zsh-fzf-tab` | Zsh プラグイン | パッケージのみ (設定は別途管理、要件7) |
| `zsh-completions` | Zsh プラグイン | パッケージのみ (設定は別途管理、要件7) |
| `zsh-history-search-multi-word` | Zsh プラグイン | パッケージのみ (設定は別途管理、要件7) |
| `zsh-fast-syntax-highlighting` | Zsh プラグイン | パッケージのみ (設定は別途管理、要件7) |

### 2.5 shell-hook モジュールの設計

要件3に合致した読み込み順制御のみを担うシンプルなモジュール:

- **3フェーズ構成**: `preload.d` → `main.d` → `postload.d`
- **優先度制御**: 数値の小さい順に読み込み (10: 最初, 50: 標準, 90: 最後)
- **命名規則**: `{priority}-{ファイル名}` (例: `10-zinit.zsh`, `50-envvar.zsh`)
- **symlink ベース**: Nix store 内のファイルへの symlink を `xdg.configFile` で配置
- **ローダー (`hook.sh`)**: 各フェーズディレクトリを順に走査して source する自動生成スクリプト

### 2.6 要件との適合性分析

| 要件 | 現状の適合度 | 詳細 |
|------|-------------|------|
| 要件1: クロスプラットフォーム | **不適合** | `flake.nix` で `system = "x86_64-linux"` がハードコードされている。arm64-linux, aarch64-darwin 等への対応機構がない |
| 要件2: lean dotfiles | **適合** | ツール設定は素のシェルスクリプトとして `config/` に配置されており、home-manager 非依存の形式を維持。`programs.*` は使用していない |
| 要件3: シンプルなモジュール | **適合** | `shell-hook.nix` は読み込み順制御のみを実装しており、ツール間の依存解決はしていない |
| 要件4: ログインシェル非管理 | **概ね適合** | `programs.zsh` は使わず `.zshrc` を直接生成。ただし `.zshrc` の生成自体と一部スクリプト (`zsh/` 配下) が Zsh 固有で、bash/fish で同等の仕組みを使う経路が未整備 |
| 要件5: プラグインマネージャはローダー専任 | **適合** | zinit は `zinit.zsh` でプラグインの source のみに使用。パッケージのバージョン管理は home-manager の `home.packages` + `flake.lock` で厳密管理 |
| 要件6: base + override | **不適合** | `home.nix` に全パッケージがフラットに列挙されており、環境別の切り替え機構がない |
| 要件7: 未設定コードの保持 | **適合** | 設定が別途管理されている bat, fd, fzf 等のパッケージは削除せず保持する |

---

## 3. 設計原則

1. **home-manager の役割限定**: home-manager は「パッケージ管理」と「ファイル配置」に徹する。ツールの設定ファイル自体は素のシェルスクリプト / 標準形式で記述し、`programs.*` による設定生成は使わない。home-manager が生成してよいのは、設定ファイルを読み込むためのローダー (`hook.sh`) や rc ファイルのエントリポイント (`.zshrc`) に限る
2. **読み込み順制御のみ**: `shell-hook` モジュールは読み込み順 (フェーズ + 優先度) の制御のみを担い、ツール間の依存解決やツール固有のロジックを持たない
3. **パッケージ管理と設定の分離**: パッケージのインストール (`home.packages`) と設定ファイルの配置 (`config/`) は別の関心事として分離する。Nix はパッケージのバージョンを厳密に管理し、設定ファイルはポータブルな形式を保つ
4. **クロスプラットフォーム共通化**: Linux (x86_64, arm64) / Darwin の差異は `flake.nix` の system パラメータとモジュールの条件分岐で吸収し、`home.nix` およびシェルスクリプト群は最大限共通で使う
5. **環境別オーバーライド**: base となるパッケージ/設定セットの上に、環境固有の差分を重ねる層構造を持つ。`imports` と Nix モジュールシステムの `mkDefault` / `mkForce` を活用する
6. **ログインシェル非依存**: ログインシェルの管理は対象外とし、`.zshrc` 等の rc ファイルの配置で対応する。設定ファイルはアプリケーション単位で `config/` 配下に整理し、シェル互換性は各スクリプトを登録する側の責務とする
7. **削除より追加**: 未設定のパッケージやスクリプトは将来の設定反映を前提として保持する。不要と判断した場合のみ明示的に削除する

---

## 4. 改善方針

### 4.1 クロスプラットフォーム対応 (要件1)

現状 `flake.nix` で `system = "x86_64-linux"` がハードコードされている。

**方針**: `flake.nix` の outputs を複数 system に対応させる。

```
flake.nix (改善後のイメージ)
├── supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]
├── system ごとに homeConfigurations を生成
└── system / OS 固有のパッケージ差分は条件分岐またはオーバーライドモジュールで吸収
```

- `nixpkgs.lib.genAttrs` や `flake-utils` 等で複数 system を列挙
- `homeConfigurations."at0x0ft@${system}"` のように system ごとの設定を生成
- シェルスクリプト群 (`config/`) は変更不要 (既にポータブル)

### 4.2 環境別オーバーライド機構 (要件6)

現状 `home.nix` に全パッケージ/設定がフラットに存在し、環境別の差分管理ができない。

**方針**: base モジュール + 環境別オーバーライドモジュールの層構造を導入する。

```
home-manager/
├── shell-hook.nix                  # 既存: フック機構 (共通基盤)
├── base.nix                         # 新規: 全環境共通のパッケージ + 設定
└── overrides/
    ├── wsl.nix                      # 新規: WSL 固有の追加/上書き
    └── darwin.nix                   # 新規: macOS 固有の追加/上書き
```

- `base.nix`: 全環境で共通のパッケージ (git, neovim, fzf 等) と共通フック
- `overrides/*.nix`: 環境固有の追加パッケージ、unfree 許可リスト、OS 固有のフック等
- `flake.nix`: system / ホスト名に応じて適切な override モジュールを `imports` に追加

### 4.3 home.nix の整理 (要件1, 6 の前提)

現状 `home.nix` がパッケージ定義、フックエントリ、.zshrc 生成を一手に担っている。

**方針**: `home.nix` は `imports` による合成と最小限のユーザー情報のみを担当する。

```
home.nix (改善後のイメージ)
├── home.username / home.homeDirectory / home.stateVersion
├── imports = [ ./home-manager/shell-hook.nix ./home-manager/base.nix ./home-manager/overrides/... ]
└── programs.home-manager.enable = true
```

- パッケージリスト → `base.nix` + override モジュールへ移動
- フックエントリ → 対応するモジュール (`base.nix` 等) へ移動
- `.zshrc` 生成 → シェル初期化専用モジュールへ移動検討 (要件4に基づきシェル種別ごとの rc 生成をまとめる)

### 4.4 マルチシェル rc ファイル生成 (要件4)

現状 `.zshrc` のみが生成され、bash/fish 用の rc ファイル生成経路がない。
`bash/direnv.bash` が存在するが `shell.hook.entries` には未登録。

**方針**: シェル種別ごとの rc ファイル生成とフックエントリ登録を整理する。

- `.zshrc`: 現状維持 (zsh 用フックを source)
- `.bashrc`: 同様のローダー構造で bash 用フックを source する生成を追加検討
- 設定ファイルはアプリケーション単位で `config/` 配下に整理済み; 特定シェル向けのスクリプト (例: `config/direnv/hook.bash`) は対応する rc 生成側で明示的に登録する
- シェル種別フィルタリングは `shell-hook.nix` の対象外 (DECISIONS.md 参照)

### 4.5 shell-hook モジュールの改善 (要件3)

モジュール内の TODO (`# TODO: refactor as config.xdg.configFile.(...).target;`) への対応。

**方針**: 要件3 (シンプルさ) を維持しつつ、`xdg.configFile` の使い方を整理する。

- 現状既に `xdg.configFile` を使用しているため、TODO の趣旨はオプション構造の整理と推測
- `baseDir` オプションを `xdg.configFile` の target パスとして一貫性を持たせる
- フェーズ / 優先度のシンプルな読み込み順制御は維持する (要件3 を遵守)

### 4.6 unfree パッケージの扱い (要件1, 6 の派生)

現状 `flake.nix` で `claude-code` のみを unfree 許可している。

**方針**: unfree 許可リストをオーバーライド可能にする。

- base で空リスト、override で環境に応じた unfree パッケージを許可する構造
- `pkgs-unfree` の生成を system に応じて動的に行う
