# '/' regard as a word delimiter.
export WORDCHARS=${WORDCHARS/\//}

# Set history variables (cite from https://github.com/sorin-ionescu/prezto/blob/master/modules/history/init.zsh)
HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zhistory}"  # The path to the history file.
HISTSIZE=10000                   # The maximum number of events to save in the internal history.
SAVEHIST=10000                   # The maximum number of events to save in the history file.

# set editor vim
export EDITOR="$(command -v nvim)"
