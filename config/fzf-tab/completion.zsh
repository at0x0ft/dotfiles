# Detect available commands and set fallbacks
_cat_cmd=$(command -v bat >/dev/null 2>&1 && echo 'bat --color=always' || echo 'head -n 500')
_cat_test=$(command -v bat >/dev/null 2>&1 && echo 'bat' || echo 'head -n 1')
_ls_cmd=$(command -v lsd >/dev/null 2>&1 && echo 'lsd -1 --color=always' || echo 'ls -1')
_delta_cmd=$(command -v delta >/dev/null 2>&1 && echo 'delta --side-by-side' || echo 'head -n 500')

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always ${(Q)realpath}'
zstyle ':fzf-tab:complete:lsd:*' fzf-preview 'bat ${(Q)realpath} >/dev/null 2>&1; if [[ "${?}" == 0 ]]; then bat --color=always ${(Q)realpath}; else lsd -1 --color=always ${(Q)realpath}; fi'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta --side-by-side'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
  'case "$group" in
  "commit tag")   git show --color=always $word ;;
  *)              git show --color=always $word | delta --side-by-side ;;
  esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
  "modified file")                git diff $word | delta --side-by-side ;;
  "recent commit object name")    git show --color=always $word | delta --side-by-side ;;
  *)                              git log --color=always $word ;;
  esac'

# Clean up temporary variables
unset _cat_cmd _cat_test _ls_cmd _delta_cmd
