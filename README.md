# World Dominators ISUCON SETUP file

ISUCONの作業環境を構築するためのレポジトリです。

## 使い方

レポジトリのインストール

```sh
git clone https://github.com/uec-world-dominators/isucon-setup
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
HOSTNAME=prod-s1
GIT_USER=prod-s1
GIT_EMAIL=test@example.com
GITHUB_SSH_URL=git@github.com:uec-world-dominators/isucon9q.git
WORKING_DIR_RELATIVE=. # Working directory relative to home directory
FIRST_PULL=false # true or false
```
