{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers.url = "github:lassulus/wrappers";
  };
  outputs = inputs@{ nixpkgs, flake-parts, wrappers, ... }:
  let
    zshModule = import ./zeno-zsh.nix;
    zshWrapperEvaled = wrappers.lib.wrapModule zshModule;
    direnvModule = import ./direnv.nix;
    direnvWrapperEvaled = wrappers.lib.wrapModule direnvModule;
  in 
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    # flake = {
    #   inherit zshModule zshWrapperEvaled;
    #   zshWrapperExtended = zshWrapperEvaled.extend { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
    #   wrapperModules = {
    #     zsh = zshModule;
    #     direnv = direnvModule;
    #   };
    # };
    perSystem = { pkgs, self', ... }: 
    let
      zshWrapperConfig = zshWrapperEvaled.apply { inherit pkgs; };
      direnvWrapperConfig = direnvWrapperEvaled.apply { inherit pkgs; nix-direnv.enable = true; };
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
        default = zshWrapperConfig.wrapper;
        direnv = direnvWrapperConfig.wrapper;
        ghd = pkgs.callPackage ./scripts/ghd {};
        foo = pkgs.writeTextDir "foo" "hello foo";
        bar = pkgs.writeText "bar" "hello bar";
      };

      devShells = {
        default = import ./nix/shell.nix { inherit pkgs; };
      };
    };
  };
}
