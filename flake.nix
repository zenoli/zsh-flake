{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers.url = "github:lassulus/wrappers";
  };
  outputs = inputs@{ flake-parts, wrappers, ... }:
  let
    zshModule = import ./zeno-zsh.nix;
    direnvModule = import ./direnv.nix;
  in 
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    flake = {
      wrapperModules = {
        zsh = zshModule;
        direnv = direnvModule;
      };
    };
    perSystem = { pkgs, self', ... }: 
    let
      loadModule =
        moduleFn:
        (moduleFn {
          wlib = wrappers.lib;
          lib = pkgs.lib;
        });
      applyWrapperModule =
        moduleFn: args:
        ((loadModule moduleFn).apply ({ inherit pkgs; } // args)).wrapper;
    in 
    {
      packages = {
        default = applyWrapperModule zshModule { direnv.package = self'.packages.direnv; };
        direnv = applyWrapperModule direnvModule {};
        ghd = pkgs.callPackage ./scripts/ghd {};
      };

      devShells = {
        default = import ./nix/shell.nix { inherit pkgs; };
      };
    };
  };
}
