{ ... }:

{
  home.username = "at0x0ft";
  home.homeDirectory = "/home/at0x0ft";
  home.stateVersion = "25.11";

  imports = [
    ./modules/shell-hooks.nix
    ./modules/base.nix
  ];

  programs.home-manager.enable = true;
}
