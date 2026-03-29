{ ... }:

{
  home.username = "at0x0ft";
  home.homeDirectory = "/home/at0x0ft";
  home.stateVersion = "25.11";

  imports = [
    ./home-manager/zinit.nix
    ./home-manager/zinit-fzf-tab-compat.nix
    ./home-manager/base.nix
  ];

  programs.home-manager.enable = true;
}
