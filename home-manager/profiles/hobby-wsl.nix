{ pkgs, pkgs-unfree, ... }:
{
  home.packages = [
    # hobby WSL machine-specific packages
    pkgs-unfree.claude-code
  ];

  shell.hook.entries = [
    {
      name = "claude-envvar";
      loader = "main";
      priority = 40;
      source = ../../config/claude/envvar.sh;
    }
  ];

  xdg.configFile."claude/CLAUDE.md" = {
    source = ../../config/claude/CLAUDE.md;
  };
}
