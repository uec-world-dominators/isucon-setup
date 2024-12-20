# World Dominators ISUCON SETUP file

ISUCONの作業環境を構築するためのレポジトリです。

## 事前準備

- `$HOME/.ssh/`にSSH秘密鍵`id_ed25519`を配置する
- 公開鍵`id_ed25519.pub`をisuconのリポジトリのdeployキーに登録する

ローカル端末からの送信例：

```sh
# 鍵ペアの作成
ssh-keygen -t ed25519 -C "isucon-server" -f ./id_ed25519 -N ""

# 公開鍵をクリップボードにコピー （これをGitHubに登録）
cat id_ed25519.pub | pbcopy

# 秘密鍵をサーバーに送信
scp ./id_ed25519 isucon9q-s1:/home/isucon/.ssh/id_ed25519
```

## 使い方

レポジトリのインストール

```sh
git clone --depth 1 https://github.com/uec-world-dominators/isucon-setup
```

環境変数の設定

```sh
cp .env.example .env
vim .env
```

セットアップの開始

```sh
make
```

ホームディレクトリにあるwebappを作業ディレクトリに移動する場合

```sh
make mv-webapp
```

環境変数の設定例

```sh
GITHUB_SSH_URL=git@github.com:uec-world-dominators/isucon9q.git # 作業レポジトリ
WORKING_DIR_RELATIVE=isucari # ホームディレクトリに対する作業ディレクトリのパス
FIRST_PULL=false # 初めてのセットアップであれば true
```
