# user@host cwd (branch)
# $
# 改行して $ を表示し、git リポジトリ内ではブランチを表示する
if declare -F __git_ps1 >/dev/null; then
  PS1='\[\e[01;32m\]\u@\h\[\e[01;33m\] \w\[\e[00m\]$(__git_ps1 " (%s)")\n\[\e[01;34m\]\$\[\e[00m\] '
else
  PS1='\[\e[01;32m\]\u@\h\[\e[01;33m\] \w\[\e[00m\]\n\[\e[01;34m\]\$\[\e[00m\] '
fi

# 端末タイトル (Ubuntu 標準 .bashrc と同等)
case "$TERM" in
  xterm*|rxvt*) PS1="\[\e]0;\u@\h: \w\a\]$PS1" ;;
esac
