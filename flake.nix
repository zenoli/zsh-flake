{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      zenoZsh = pkgs.callPackage ./zeno-zsh.nix {};
      ghd = pkgs.callPackage ./scripts/ghd {};
    in 
  {
    # APPS
    apps.${system} = {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/zeno-zsh";
      };
      ghd = {
        type = "app";
        program = "${self.packages.${system}.ghd}/bin/ghd";
      };
    };

    # PACKAGE
    packages.${system} = {
      default = zenoZsh;
      ghd = ghd;
    };

    # DEVSHELL
    devShells.${system}.default = import ./shell.nix { inherit pkgs; };

    # HOME-MANAGER MODULE
    homeManagerModules.zenoZsh = import ./zeno-zsh-module.nix;
  };
}

