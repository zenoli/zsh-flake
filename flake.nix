{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    wrappers.url = "github:lassulus/wrappers";
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
    }:
    let
      util = import ./nix/util.nix { inherit nixpkgs; };
      loadModule =
        moduleFn:
        (moduleFn {
          wlib = wrappers.lib;
          lib = nixpkgs.lib;
        });
      applyWrapperModule =
        moduleFn: pkgs: args:
        ((loadModule moduleFn).apply ({ inherit pkgs; } // args)).wrapper;
    in
    {
      wrapperModules = {
        zsh = import ./zeno-zsh.nix;
      };

      packages = util.forAllSystems (pkgs: {
        default = applyWrapperModule self.wrapperModules.zsh pkgs (import ./zsh-config.nix);
        ghd = pkgs.callPackage ./scripts/ghd { };
      });

      devShells = util.forAllSystems (pkgs: {
        default = import ./nix/shell.nix { inherit pkgs; };
      });
    };
}
