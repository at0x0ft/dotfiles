if [[ -f "$HOME/.zinit/bin/zmodules/Src/zdharma/zplugin.so" ]]; then
    module_path+=( "$HOME/.zinit/bin/zmodules/Src" )
    zmodload zdharma/zplugin
fi

# Change .zcompdump location
typeset -A ZINIT
ZINIT[ZCOMPDUMP_PATH]="$HOME/.zinit"
