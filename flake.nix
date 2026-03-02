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
      # Maps profile names to their platform (system + env).
      # Each profile becomes a homeConfigurations entry named "at0x0ft@${name}".
      # Multiple profiles may share the same (system, env) with different profiles/${name}.nix.
      profileDefs = {
        work       = { system = "x86_64-linux"; env = "wsl"; };
        individual = { system = "x86_64-linux"; env = "wsl"; };
      };

      # Unfree package allowlists per environment.
      # Defined here (outside modules) because pkgs-unfree must be built
      # before home-manager module evaluation begins.
      unfreeAllowlists = {
        wsl    = [ "claude-code" ];
        linux  = [];
        darwin = [];
      };

      platformModules = {
        wsl    = ./home-manager/platforms/wsl.nix;
        linux  = ./home-manager/platforms/linux.nix;
        darwin = ./home-manager/platforms/darwin.nix;
      };

      makeHomeConfig = profileName: { system, env }:
        let
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
            platformModules.${env}
            (./home-manager/profiles + "/${profileName}.nix")
          ];
          extraSpecialArgs = {
            inherit pkgs-unfree isDarwin isLinux;
          };
        };

    in
    {
      homeConfigurations = nixpkgs.lib.mapAttrs'
        (name: def: nixpkgs.lib.nameValuePair "at0x0ft@${name}" (makeHomeConfig name def))
        profileDefs;
    };
}
