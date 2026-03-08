{ lib, config, pkgs, ... }:

let
  cfg = config.zsh.zinit;

  pluginLines = lib.concatMapStringsSep "\n" (plugin:
    let
      iceLine = lib.optionalString (plugin.ices != [])
        "zi ice ${lib.concatStringsSep " " plugin.ices}\n";
    in
    ''
      ${iceLine}zi ${plugin.verb} "${plugin.path}"
    ''
  ) cfg.plugins;

  pluginScript = pkgs.writeText "zinit-plugins.zsh" ''
    ${pluginLines}
  '';

  initScript = pkgs.replaceVars ./zinit-init.zsh.tmpl {
    zinit_path = "${pkgs.zinit}/share/zinit";
  };
in
{
  imports = [ ./shell-hook.nix ];

  options.zsh.zinit = {
    enable = lib.mkEnableOption "zinit plugin loader for zsh";

    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule ({ ... }: {
        options = {
          verb = lib.mkOption {
            type = lib.types.enum [ "snippet" "light" "load" ];
            description = "zinit load verb";
          };

          path = lib.mkOption {
            type = lib.types.str;
            description = "Plugin path or spec passed to zinit";
          };

          ices = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "zinit ice options";
          };
        };
      }));
      default = [];
      description = "Plugins to load through zinit";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.zinit ];

    shell.hook.entries =
      [
        {
          loader = "main";
          priority = 10;
          source = initScript;
        }
      ]
      ++ lib.optionals (cfg.plugins != []) [
        {
          loader = "main";
          priority = 20;
          source = pluginScript;
        }
      ];
  };
}
