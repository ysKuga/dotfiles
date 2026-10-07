# fzf: Ctrl-R (履歴), Ctrl-T (ファイル), Alt-C (cd) のキーバインドと ** 補完
# fzf は mise 管理のため mise.sh より後に読み込まれるよう zz- を付けている
if command -v fzf >/dev/null; then
  eval "$(fzf --bash)"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
fi
