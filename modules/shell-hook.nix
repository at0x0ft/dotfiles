{ lib, config, pkgs, ... }:

let
  types = lib.types;
  hook = config.shell.hook;

  entryToFileName = entry:
    lib.fixedWidthNumber 2 entry.priority + "-" + baseNameOf entry.source;
in
{
  options.shell.hook = {
    baseDir = lib.mkOption {
      type = types.str;
      default = "home-manager/shell-hook";
      description = "Base directory under XDG_CONFIG_HOME";
    };

    scriptPath = lib.mkOption {
      type = types.str;
      default = "${hook.baseDir}/hook.sh";
      description = "Hook script path under XDG_CONFIG_HOME";
    };

    phaseOrder = lib.mkOption {
      type = types.attrsOf types.int;
      default = {
        preload  = 0;
        main     = 1;
        postload = 2;
      };
      description = "Phase name to sort order mapping. Lower number loads first. Add new phases here to extend without modifying this module.";
    };

    entries = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          loader = lib.mkOption {
            type = types.str;
            description = "Load phase (must be a key in shell.hook.phaseOrder)";
          };

          priority = lib.mkOption {
            type = types.int;
            default = 50;
            description = "Load priority within a phase (lower loads earlier)";
          };

          source = lib.mkOption {
            type = types.path;
            description = "Source file to be sourced by shell";
          };
        };
      });
      default = [];
    };
  };

  config = {
    xdg.configFile = lib.mkMerge [
      # create symlinks in {padded_order}-{phase}.d/ directories
      (lib.mkMerge (map
        (entry: let
          order = lib.fixedWidthNumber 2 hook.phaseOrder.${entry.loader};
          dir   = "${hook.baseDir}/${order}-${entry.loader}.d";
          name  = entryToFileName entry;
        in
        {
          "${dir}/${name}".source = entry.source;
        })
        hook.entries
      ))

      # generate hook.sh from template
      {
        "${hook.scriptPath}".source = pkgs.replaceVars
          ../shell-hook-sources/hook.sh.tmpl
          { base_dir = "${config.xdg.configHome}/${hook.baseDir}"; };
      }
    ];
  };
}
