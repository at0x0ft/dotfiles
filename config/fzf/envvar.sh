# Detect available commands and set fallbacks
_fd_cmd=$(command -v fd >/dev/null 2>&1 && echo 'fd --type f' || echo 'find . -type f')
_cat_cmd=$(command -v bat >/dev/null 2>&1 && echo 'bat --color=always' || echo 'cat')
_ls_cmd=$(command -v lsd >/dev/null 2>&1 && echo 'lsd -1 --color=always' || echo 'ls -1')

# FZF_DEFAULT_COMMAND: use fd if available, otherwise fall back to find
export FZF_DEFAULT_COMMAND="${_fd_cmd}"

# FZF_COMPLETION_OPTS: preview with bat/lsd or cat/ls
export FZF_COMPLETION_OPTS="--preview '${_cat_cmd} {} 2>/dev/null || ${_ls_cmd} {}'"

# Clean up temporary variables
unset _fd_cmd _cat_cmd _ls_cmd
