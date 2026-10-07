# problems

気になった問題など書いていく。
問題があるかどうかの判定、解決などを検討

## 起動直後の表示

Ubuntu インストール後に起動したところ以下のような表示が行われた。

- root 権限を必要としているものを何か実行している？

```sh
PS C:\Users\kenne> wsl ~
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

Welcome to Ubuntu 24.04.5 LTS (GNU/Linux 6.18.40.1-microsoft-standard-WSL2 x86_64)
```

### 結論: 問題なし

root 権限で何かが実行されているわけではない。

- `To run a command as administrator ...`
  - `/etc/bash.bashrc` の sudo hint による案内表示
  - `~/.sudo_as_admin_successful` が無い場合に表示され、一度 sudo を実行すると作成されて出なくなる
- `Welcome to Ubuntu ...`
  - ログイン時の motd（`/etc/update-motd.d/`）
  - 非表示にしたい場合は `touch ~/.hushlogin`（いったん対応しない）
