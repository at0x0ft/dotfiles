{
  description = "Home Manager configuration of at0x0ft";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # Maps each system string to a logical environment name.
      # Edit this when adding support for a new machine or system type.
      systemEnvironment = {
        "x86_64-linux"   = "wsl";
        "aarch64-linux"  = "linux";
        "aarch64-darwin" = "darwin";
      };

      # Unfree package allowlists per environment.
      # Defined here (outside modules) because pkgs-unfree must be built
      # before home-manager module evaluation begins.
      unfreeAllowlists = {
        wsl    = [ "claude-code" ];
        linux  = [];
        darwin = [];
      };

      overrideModules = {
        wsl    = ./home-manager/overrides/wsl.nix;
        linux  = ./home-manager/overrides/linux.nix;
        darwin = ./home-manager/overrides/darwin.nix;
      };

      makeHomeConfig = system:
        let
          env = systemEnvironment.${system};
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-unfree = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) unfreeAllowlists.${env};
          };
          isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
          isLinux  = nixpkgs.lib.hasSuffix "-linux"  system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            overrideModules.${env}
          ];
          extraSpecialArgs = {
            inherit pkgs-unfree isDarwin isLinux;
          };
        };

    in
    {
      homeConfigurations = builtins.listToAttrs (map
        (system: {
          name  = "at0x0ft@${system}";
          value = makeHomeConfig system;
        })
        supportedSystems
      );
    };
}
