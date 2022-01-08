# zinit ice wait lucid
zinit light zdharma-continuum/zinit-annex-bin-gem-node

zinit ice wait lucid from"gh-r" mv"lsd* -> lsd" sbin"**/lsd(.exe|) -> lsd"
zinit load Peltoche/lsd
alias ls='lsd --color=always'

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

# not available fzf-completion
# zinit pack"bgn-binary" for fzf
zinit ice wait lucid from"gh-r" sbin"fzf -> fzf"
zinit load junegunn/fzf
zinit ice wait lucid pick"shell/completion.zsh" id-as"junegunn/fzf_completion"
zinit load junegunn/fzf


zinit ice wait lucid blockf
zinit load Aloxaf/fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always ${(Q)realpath}'
zstyle ':fzf-tab:complete:lsd:*' fzf-preview 'bat --color=always ${(Q)realpath}'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta --side-by-side'|
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
