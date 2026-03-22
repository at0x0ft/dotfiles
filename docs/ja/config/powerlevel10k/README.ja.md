# Powerlevel10k 設定管理

- **ベースバージョン**: Powerlevel10k v1.20.15
- **ベーステーマ**: p10k-lean.zsh
- **最終更新日**: 2026-03-22

## バージョン履歴

- **2026-03-22**: 初期レイヤード設定（p10k v1.20.15 からのベース）
  - ユーザーカスタマイズ: 左プロンプトに context/os_icon、awesome-fontconfig モード、コンパクトレイアウト
- **2021-03-26**: オリジナルのモノリシック設定（チェックサム 43791、p10k-lean.zsh ベース）

## アーキテクチャ

メンテナンス可能な p10k バージョンアップグレードのためのレイヤード設定：

```
p10k.zsh (ローダー)          # 読み込みの調整、p10k リロード処理
├─ p10k-base.zsh            # p10k configure で生成（バージョン管理）
└─ p10k-custom.zsh          # ユーザーのオーバーライド（アップグレード時も保持）
```

### 設計原則

1. **関心の分離**: ベース設定は上流のデフォルト、カスタム設定はあなたの変更のみを含む
2. **オーバーライド優先順位**: カスタム設定が自動的にベースを上書き（ソース順による）
3. **アップグレードの安全性**: `p10k configure` はベースファイルのみを再生成し、カスタマイズを保持
4. **ホットリロード**: カスタムファイルへの変更は `source` コマンドで即座に反映
5. **バージョン追跡**: ベースファイルのヘッダーに p10k のバージョンを記録

## ファイル

- **p10k.zsh**: 無名関数ラッパーを提供し、ベースとカスタムの両方をソースするローダースクリプト
- **p10k-base.zsh**: ベーステーマ設定（p10k-lean.zsh からの typeset 文）
- **p10k-custom.zsh**: ユーザーカスタマイズ（ベースと異なる変数のみ）
- **instant-prompt.zsh**: インスタントプロンプトのブートストラップ（標準 p10k から変更なし）

## 変更を加える

### プロンプトのカスタマイズ

`p10k-custom.zsh` を編集してプロンプトをカスタマイズします：

```bash
vim config/powerlevel10k/p10k-custom.zsh
# typeset -g POWERLEVEL9K_* 変数を追加/修正

# 現在のシェルでリロード
source ~/.config/zsh/hook/p10k.zsh  # （またはローダーが配置されている場所）
```

**例**: 新しいセグメントを追加するか色を変更

```zsh
# p10k-custom.zsh 内：
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=220  # user@host の色を変更
typeset -g POWERLEVEL9K_DIR_BACKGROUND=25       # ディレクトリの背景を変更
```

### ガイドライン

- **ベースと異なる**変数のみを `p10k-custom.zsh` に追加する
- ベースファイルと同じ `typeset -g` フォーマットを使用する
- 関連する設定をコメントでグループ化して明確にする
- メンテナンスを容易にするため、カスタマイズは最小限に保つ

## Powerlevel10k のアップグレード

Nix 設定で `pkgs.zsh-powerlevel10k` をアップグレードする際は、以下の手順に従います：

### ステップ 1: 新しいベースを生成

以前と同じテーマ選択で p10k 設定ウィザードを実行します：

```bash
p10k configure

# ウィザードオプション（元の選択）：
# - awesome-fontconfig + powerline
# - small icons, unicode
# - lean style
# - 24h time
# - 2 lines, dotted, no frame
# - lightest-ornaments
# - compact, many icons, concise
# - transient_prompt
# - instant_prompt=verbose

# 新しいベース候補として保存
mv ~/.p10k.zsh config/powerlevel10k/p10k-base-NEW.zsh
```

### ステップ 2: 変更を比較

新しいバージョンで何が変わったかをレビューします：

```bash
# 旧ベースと新ベースを比較
diff -u config/powerlevel10k/p10k-base.zsh \
        config/powerlevel10k/p10k-base-NEW.zsh > p10k-upgrade.diff

# diff を確認：
# - 新しいセグメント/オプション（必要に応じてカスタムに採用）
# - 非推奨の設定（カスタムに存在する場合は削除）
# - 破壊的変更（カスタムのオーバーライドを適応）
# - デフォルト値の変更（古いデフォルトに依存していた場合はカスタムを更新）
```

### ステップ 3: カスタムオーバーライドを更新

diff に基づいて `p10k-custom.zsh` を調整します：

- **変数名の変更**: カスタム内の変数名を更新
- **新機能**: 設定したい場合は新しいオプションをカスタムに追加
- **非推奨の設定**: もう存在しない場合はカスタムから削除
- **意味の変更**: 動作が変更された場合はカスタムの値を調整

### ステップ 4: ベースを置き換え

新しいベースで動作するようにカスタムを更新したら：

```bash
# 旧ベースをバックアップ（必要に応じてロールバック用）
mv config/powerlevel10k/p10k-base.zsh \
   config/powerlevel10k/p10k-base-OLD.zsh

# 新しいベースをインストール
mv config/powerlevel10k/p10k-base-NEW.zsh \
   config/powerlevel10k/p10k-base.zsh
```

### ステップ 5: テスト

```bash
# Nix 設定を適用
home-manager switch --flake '.#at0x0ft@work'

# 新しいシェルを開いて確認：
# - インスタントプロンプトが素早く表示される
# - プロンプトの外観が期待通り
# - すべてのセグメントが正しく動作
# - カスタムオーバーライドが適用されている

# 特定の変数を確認
echo $POWERLEVEL9K_MODE  # カスタム値が表示されるはず
```

### ステップ 6: コミット（オプションだが推奨）

簡単にロールバックできるよう、git でベースバージョンを追跡します：

```bash
git add config/powerlevel10k/p10k-base.zsh
git commit -m "chore(p10k): update base config to v1.XX.X"
git tag p10k-base-v1.XX.X

# 後でバージョンを比較：
git diff p10k-base-v1.19.0..p10k-base-v1.20.0 -- config/powerlevel10k/p10k-base.zsh
```

## 現在のカスタマイズの特定

カスタマイズした変数を確認する方法（アップグレード前に便利）：

```bash
# 両方のファイルから変数を抽出して比較
sed -n '/^  typeset -g POWERLEVEL9K_/p' config/powerlevel10k/p10k-base.zsh | sort > /tmp/base-vars.txt
sed -n '/^typeset -g POWERLEVEL9K_/p' config/powerlevel10k/p10k-custom.zsh | sort > /tmp/custom-vars.txt

# カスタマイズ内容を表示
diff -u /tmp/base-vars.txt /tmp/custom-vars.txt
```

または現在の Nix ストアバージョンと比較：

```bash
BASE_THEME=$(find /nix/store -name "p10k-lean.zsh" -path "*/powerlevel10k*/config/*" 2>/dev/null | head -1)

# typeset 文を抽出して比較
sed -n '/^() {$/,/^}$/p' "$BASE_THEME" | \
  grep "^  typeset -g POWERLEVEL9K_" > /tmp/store-vars.txt

# カスタムとストアベースを比較
diff -u /tmp/store-vars.txt /tmp/custom-vars.txt | grep "^[+]typeset"
```

## トラブルシューティング

### インスタントプロンプトキャッシュの問題

変更後にプロンプトが更新されない場合：

```bash
# インスタントプロンプトキャッシュをクリア
rm ~/.cache/p10k-instant-prompt-*

# シェルを再起動
exec zsh
```

### オーバーライドが機能しない

1. カスタムファイルの構文が正しいか確認（変数名にタイポがないか）
2. ローダー内のソース順序を確認（base → custom）
3. 単独でテスト：

```bash
# ベースのみをソース
zsh -c 'source config/powerlevel10k/p10k-base.zsh && echo $POWERLEVEL9K_MODE'

# ベース + カスタムをソース
zsh -c 'source config/powerlevel10k/p10k-base.zsh && source config/powerlevel10k/p10k-custom.zsh && echo $POWERLEVEL9K_MODE'
```

### p10k configure が間違ったファイルを上書き

ローダーは `POWERLEVEL9K_CONFIG_FILE` をベースに設定します。それでも `p10k configure` が間違ったファイルを上書きする場合：

1. ローダーがソースされているか確認（古いモノリシックファイルではなく）
2. POWERLEVEL9K_CONFIG_FILE のパスを確認：

```bash
echo $POWERLEVEL9K_CONFIG_FILE
# 次のパスを指すべき: /path/to/config/powerlevel10k/p10k-base.zsh
```

## このアプローチの利点

1. **明確な分離**: 上流のデフォルトとユーザー設定が明示的
2. **簡単なアップグレード**: ベースを再生成、diff をレビュー、必要に応じてカスタムを更新
3. **ロールバック機能**: Git タグにより以前のベースバージョンに戻すことが可能
4. **ポータブルなカスタマイズ**: カスタムファイルは簡潔で自己文書化
5. **手動マージ不要**: 面倒な行ごとの設定調整を回避
6. **将来性**: 新しい p10k 機能が自動的に利用可能（カスタムでオプトイン）
7. **最小限のメンテナンス**: カスタムファイルは新しいカスタマイズを追加した時のみ増える
8. **diff フレンドリー**: Git 履歴でカスタム変更とベース再生成を分離して表示

## 参考資料

- [Powerlevel10k ドキュメント](https://github.com/romkatv/powerlevel10k)
- [p10k 設定](https://github.com/romkatv/powerlevel10k#configuration)
- [インスタントプロンプト](https://github.com/romkatv/powerlevel10k#instant-prompt)
