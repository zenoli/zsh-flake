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
    util = import ./nix/util.nix { inherit nixpkgs; };
  in 
  {
    packages = util.forAllSystems (pkgs: {
      default = pkgs.callPackage ./zeno-zsh.nix {};
      ghd = pkgs.callPackage ./scripts/ghd {};
    });

    devShells = util.forAllSystems (pkgs: {
      default = import ./nix/shell.nix { inherit pkgs; };
    });

    homeManagerModules.zenoZsh = import ./zeno-zsh-module.nix;
  };
}

