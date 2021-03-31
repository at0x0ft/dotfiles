# Load history and directory snippet from Prezto modules
# zinit ice svn
# zinit snippet PZTM::history

# zinit ice wait lucid blockf
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zinit ice wait lucid
zinit light Aloxaf/fzf-tab
