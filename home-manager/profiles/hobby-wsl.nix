{ pkgs, pkgs-unfree, ... }:
{
  home.packages = [
    # hobby WSL machine-specific packages
    pkgs-unfree.claude-code
  ];

  shell.hook.entries = [
    {
      loader = "main";
      priority = 50;
      source = ../../config/claude/envvar.sh;
    }
  ];

  xdg.configFile."claude/CLAUDE.md" = {
    source = ../../config/claude/CLAUDE.md;
  };
}
