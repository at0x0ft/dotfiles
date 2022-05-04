if [[ -f "$HOME/.local/share/zinit/modules/Src/zdharma_continuum/zinit.so" ]]; then
  module_path+=( "$HOME/.local/share/zinit/modules/Src" )
  zmodload zdharma_continuum/zinit
fi
