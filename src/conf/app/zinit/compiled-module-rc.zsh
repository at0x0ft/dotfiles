if [[ -f "$HOME/.local/share/zinit/bin/zmodules/Src/zdharma_continuum/zplugin.so" ]]; then
    module_path+=( "$HOME/.local/share/zinit/bin/zmodules/Src" )
    zmodload zdharma_continuum/zinit
fi
