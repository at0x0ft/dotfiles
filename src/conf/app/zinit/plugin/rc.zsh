# zinit ice wait lucid
zinit light zdharma-continuum/zinit-annex-bin-gem-node

zinit ice wait lucid from"gh-r" mv"exa* -> exa" sbin"bin/exa -> exa"
zinit load ogham/exa
alias ls='exa -bh --color=auto'

zinit ice wait lucid from"gh-r" mv"bat* -> bat" sbin"**/bat(.exe|) -> bat"
zinit load sharkdp/bat

zinit ice wait lucid from"gh-r" mv"delta* -> delta" sbin"**/delta(.exe|) -> delta"
zinit load dandavison/delta
function ddiff() {
    diff -u ${1} ${2} | delta --side-by-side
}

# zinit ice wait lucid from"gh-r" as"program" mv"direnv* -> direnv" atclone"./direnv hook zsh > zhook.zsh" atpull"%atclone" pick"direnv" src"zhook.zsh"
# zinit ice wait lucid from"gh-r" mv"direnv* -> direnv" sbin"direnv* -> direnv"
# zinit load direnv/direnv
# start direnv source ( = zhook.zsh)
# _direnv_hook() {
#   trap -- '' SIGINT;
#   eval "$("${HOME}/.zinit/polaris/bin/direnv" export zsh)";
#   trap - SIGINT;
# }
# typeset -ag precmd_functions;
# if [[ -z ${precmd_functions[(r)_direnv_hook]} ]]; then
#   precmd_functions=( _direnv_hook ${precmd_functions[@]} )
# fi
# typeset -ag chpwd_functions;
# if [[ -z ${chpwd_functions[(r)_direnv_hook]} ]]; then
#   chpwd_functions=( _direnv_hook ${chpwd_functions[@]} )
# fi
# end direnv source

zinit pack"default+keys" for fzf

zinit ice wait lucid blockf
zinit load Aloxaf/fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# zstyle ':fzf-tab:complete:ls:*' fzf-preview 'bat --color=always {}'
