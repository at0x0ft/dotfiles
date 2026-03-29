{ pkgs, pkgs-unfree, ... }:
{
  home.packages = [
    # hobby WSL machine-specific packages
    pkgs-unfree.claude-code
  ];
}
