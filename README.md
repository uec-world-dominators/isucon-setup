# World Dominators ISUCON SETUP file

ISUCONの作業環境を構築するためのレポジトリです。

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
```
