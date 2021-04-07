zinit light zinit-zsh/z-a-bin-gem-node

zinit ice wait lucid from"gh-r" mv"exa* -> exa" sbin"bin/exa -> exa"
zinit load ogham/exa
alias ls='exa -bh --color=auto'

zinit ice wait lucid from"gh-r" mv"bat* -> bat" sbin"**/bat(.exe|) -> bat"
zinit load sharkdp/bat

zinit ice wait lucid from"gh-r" mv"delta* -> delta" sbin"**/delta(.exe|) -> delta"
zinit load dandavison/delta
function ddiff() {
    diff -u ${1} ${2} | delta
}

zinit ice wait lucid from"gh-r" sbin"fzf -> fzf"
zinit load junegunn/fzf
zinit ice wait lucid pick"shell/completion.zsh" id-as"junegunn/fzf_completion"
zinit load junegunn/fzf

zinit ice wait lucid blockf
zinit load Aloxaf/fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# zstyle ':fzf-tab:complete:ls:*' fzf-preview 'bat --color=always {}'
