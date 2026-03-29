{ lib, pkgs, ... }:

{
  options.zinit.packages = {
    fzf-tab-compat = lib.mkOption {
      type = lib.types.package;
      default = pkgs.runCommand "zsh-fzf-tab-without-module" { } ''
        cp -r ${pkgs.zsh-fzf-tab}/share/fzf-tab "$out"
        chmod -R u+w "$out"
        rm -f "$out"/modules/Src/aloxaf/fzftab.so "$out"/modules/Src/aloxaf/fzftab.bundle
      '';
      description = "fzf-tab package with compiled modules removed for zinit compatibility (avoids GLIBC version mismatch)";
    };
  };
}
