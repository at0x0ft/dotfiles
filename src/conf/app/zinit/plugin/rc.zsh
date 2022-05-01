# zinit ice wait lucid
zinit light zdharma-continuum/zinit-annex-bin-gem-node

zinit ice wait lucid from"gh-r" mv"lsd* -> lsd" sbin"**/lsd(.exe|) -> lsd"
zinit load Peltoche/lsd
alias ls='lsd --color=always'

zinit ice wait lucid from"gh-r" mv"bat* -> bat" sbin"**/bat(.exe|) -> bat"
zinit load sharkdp/bat

zinit ice wait lucid from"gh-r" mv"fd* -> fd" sbin"**/fd(.exe|) -> fd"
zinit load sharkdp/fd

zinit ice wait lucid from"gh-r" mv"delta* -> delta" sbin"**/delta(.exe|) -> delta"
zinit load dandavison/delta
function ddiff() {
    diff -u "${1}" "${2}" | delta --side-by-side
}

# zinit ice wait lucid from"gh-r" as"program" mv"direnv* -> direnv" atclone"./direnv hook zsh > zhook.zsh" atpull"%atclone" pick"direnv" src"zhook.zsh"
# zinit ice wait lucid from"gh-r" mv"direnv* -> direnv" sbin"direnv* -> direnv"
# zinit load direnv/direnv
# start direnv source ( = zhook.zsh)
# _direnv_hook() {
#   trap -- '' SIGINT;
#   eval "$("${HOME}/.local/share/zinit/polaris/bin/direnv" export zsh)";
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
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_COMPLETION_OPTS='--preview '"'"'bat {} >/dev/null 2>&1; if [[ "${?}" == 0 ]]; then bat --color=always {}; else lsd -1 --color=always {}; fi'"'"

function dcd() {
    # ref: https://stackoverflow.com/questions/55186799/multi-process-bash-within-fzf-preview-feature
    # ref (how to embed tab character) : https://mattintosh.hatenablog.com/entry/2013/01/16/143323
    local dirs_number=$(dirs -v | fzf --preview 'readonly selected={} && eval "lsd -1 --color=always ${selected#*$'"'"'\t'"'"'}"' | cut -f 1)
    if [[ ! -z "${dirs_number}" ]]; then cd +"${dirs_number}"; fi
}

if type realpath > /dev/null 2>&1; [ "${#}" -ne 0 ]; then
    # ref: https://github.com/ko1nksm/readlinkf/blob/master/readlinkf.sh
    function realpath() {
        [ "${1:-}" ] || return 1
        max_symlinks=40
        CDPATH='' # to avoid changing to an unexpected directory

        target=$1
        [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
        [ -d "${target:-/}" ] && target="$target/"

        cd -P . 2>/dev/null || return 1
        while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
            if [ ! "$target" = "${target%/*}" ]; then
                case $target in
                    /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
                    *) cd -P "./${target%/*}" 2>/dev/null || break ;;
                esac
                target=${target##*/}
            fi

            if [ ! -L "$target" ]; then
                target="${PWD%/}${target:+/}${target}"
                printf '%s\n' "${target:-/}"
                return 0
            fi

            # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
            #   <file mode>, <number of links>, <owner name>, <group name>,
            #   <size>, <date and time>, <pathname of link>, <contents of link>
            # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
            link=$(ls -dl -- "$target" 2>/dev/null) || break
            target=${link#*" $target -> "}
        done
        return 1
    }
fi

zinit ice wait lucid blockf
zinit load Aloxaf/fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always ${(Q)realpath}'
zstyle ':fzf-tab:complete:lsd:*' fzf-preview 'bat ${(Q)realpath} >/dev/null 2>&1; if [[ "${?}" == 0 ]]; then bat --color=always ${(Q)realpath}; else lsd -1 --color=always ${(Q)realpath}; fi'
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
