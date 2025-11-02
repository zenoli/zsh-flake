{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers.url = "github:lassulus/wrappers";
  };

  outputs = { self, nixpkgs, home-manager, wrappers }: 
  let
    util = import ./nix/util.nix { inherit nixpkgs; };
    applyWrapperModule = moduleFn: pkgs: args:
    ((moduleFn { 
      wlib = wrappers.lib; 
      lib = nixpkgs.lib; 
    }).apply ({ inherit pkgs; } // args)).wrapper;
  in 
  {
    packages = util.forAllSystems (pkgs: {
      default = pkgs.callPackage ./zeno-zsh.nix {};
      ghd = pkgs.callPackage ./scripts/ghd {};
      zsh2 = applyWrapperModule (import ./zeno-zsh2.nix) pkgs {};
    });

    devShells = util.forAllSystems (pkgs: {
      default = import ./nix/shell.nix { inherit pkgs; };
    });

    homeManagerModules.zenoZsh = import ./zeno-zsh-module.nix;
  };
}

