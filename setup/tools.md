# 各種インストール対象

WSL 環境に入れるツールの一覧。mise で入れられるものは [mise/global.toml](../mise/global.toml) に追加する。

## nvm → node (mise)

<https://github.com/nvm-sh/nvm>

Node.js のバージョン管理。mise の node で置き換え、`.nvmrc` も mise が読む。

## fzf (mise)

<https://github.com/junegunn/fzf>

コマンド履歴・ファイルなどのあいまい検索。

## eza (mise)

<https://github.com/eza-community/eza>

`ls` の代替。色分け・アイコン・Git 状態の表示。

## bat (mise)

<https://github.com/sharkdp/bat>

`cat` の代替。シンタックスハイライト・行番号の表示。

## ripgrep (mise)

<https://github.com/BurntSushi/ripgrep>

高速な grep。
VS Code 拡張 Todo-Tree が同梱 rg を見つけられない (`Failed to find vscode-ripgrep`) ため、mise の shim を指定する。
端末固有の絶対パスになるため dotfiles 管理外とし、WSL 側の Machine 設定 `~/.vscode-server/data/Machine/settings.json` に書く。

```json
{
  "todo-tree.ripgrep.ripgrep": "/home/<user>/.local/share/mise/shims/rg"
}
```

## Docker Engine (未導入)

<https://docs.docker.com/engine/install/ubuntu/>

コンテナ実行環境。Docker Desktop を使わず WSL 内に直接入れる。デーモンのため mise では入れられず、apt (sudo) で導入する。
