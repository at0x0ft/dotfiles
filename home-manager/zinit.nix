{ lib, config, pkgs, ... }:

let
  cfg = config.zsh.zinit;

  # Group plugins by priority
  groupedByPriority = lib.foldl' (acc: plugin:
    let
      p = toString plugin.priority;
      existing = acc.${p} or [];
    in
    acc // { ${p} = existing ++ [ plugin ]; }
  ) {} cfg.plugins;

  # Generate a zinit script for a list of plugins
  pluginLinesToScript = plugins:
    lib.concatMapStringsSep "\n" (plugin:
      let
        iceLine = lib.optionalString (plugin.ices != [])
          "zi ice ${lib.concatStringsSep " " plugin.ices}\n";
      in
      ''
        ${iceLine}zi ${plugin.verb} "${plugin.path}"
      ''
    ) plugins;

  # Derive a group name from the first plugin that has a name, or fall back to priority
  groupName = priority: plugins:
    let
      named = lib.filter (p: p.name != null) plugins;
      base = if named != [] then (lib.head named).name else "plugins-${priority}";
    in
    "zinit-${base}.zsh";

  # Generate one script file per priority group
  priorityScripts = lib.mapAttrsToList (priority: plugins:
    let
      fileName = groupName priority plugins;
    in
    {
      inherit priority fileName;
      source = pkgs.writeText fileName (pluginLinesToScript plugins);
    }
  ) groupedByPriority;

  initScript = pkgs.replaceVars ./zinit-init.zsh.tmpl {
    zinit_path = "${pkgs.zinit}/share/zinit";
  };
in
{
  imports = [ ./shell-hook.nix ];

  options.zsh.zinit = {
    enable = lib.mkEnableOption "zinit plugin loader for zsh";

    initLoader = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Shell-hook loader phase for the zinit initialization script (must be a key in shell.hook.phaseOrder)";
    };

    initPriority = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Shell-hook priority for the zinit initialization script (must load before any plugins)";
    };

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

          priority = lib.mkOption {
            type = lib.types.int;
            default = 20;
            description = "Shell-hook priority for this plugin (lower loads earlier)";
          };

          name = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Name for the generated script and shell-hook symlink (without 'zinit-' prefix and '.zsh' suffix)";
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
          loader = cfg.initLoader;
          priority = cfg.initPriority;
          name = "zinit-init.zsh";
          source = initScript;
        }
      ]
      ++ map (ps: {
        loader = "main";
        priority = lib.toInt ps.priority;
        name = ps.fileName;
        source = ps.source;
      }) priorityScripts;
  };
}
