# zsh-users/fast-syntax-highlighting
zinit ice wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
zinit light zdharma/fast-syntax-highlighting

# prezto completion
zinit ice svn blockf
zinit snippet PZTM::completion
zinit cdclear -q

# docker completion
zinit ice as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

# docker-compose completion
zinit ice as"completion"
zinit snippet https://github.com/docker/compose/blob/master/contrib/completion/zsh/_docker-compose

# zsh-users/autosuggestions
zinit ice wait lucid atload"!_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Load history and directory snippet from Prezto modules
zinit snippet PZTM::history
zinit snippet PZTM::directory

# zdharma/history-search-multi-word
zstyle ":history-search-multi-word" page-size "11"
zinit ice wait"1" lucid
zinit load zdharma/history-search-multi-word

# Load the pure theme, with zsh-async library that's bundled with it.
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

# Enable completion
zinit wait lucid atload"zicompinit; zicdreplay" blockf for \
    zsh-users/zsh-completions
