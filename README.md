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
scp ./id_ed25519 isucon9q-prod-s1:/home/isucon/.ssh/id_ed25519
```

## 使い方

レポジトリのインストール

```sh
git clone --depth 1 https://github.com/uec-world-dominators/isucon-setup
```

環境変数の設定

```sh
cp env.example env
vim env
```

セットアップの開始

```sh
make
```

環境変数の設定例

```sh
CONTEST=isucon9q # isucon9予選
STACK=prod # 本番環境 or 作業環境 (ユーザー名)
SERVER_ID=s1 # サーバー1 (メイン)
GIT_EMAIL=prod@example.com
GITHUB_SSH_URL=git@github.com:uec-world-dominators/isucon9q.git # 作業レポジトリ
WORKING_DIR_RELATIVE=isucari # ホームディレクトリに対する作業ディレクトリのパス
FIRST_PULL=false # 初めてのセットアップであれば true

S1_PUBLIC_KEY=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICInNg79abEccf2FkN417hETR0Ff8RcegRiXMHmjcg8D isucon-app
S2_IP=10.204.104.160
S3_IP=10.204.104.161
```
