{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    wrappers.url = "github:lassulus/wrappers";
  };
  outputs = inputs@{ nixpkgs, flake-parts, wrappers, ... }:
  let
    wlib = wrappers.lib;
    zshModule = import ./zeno-zsh.nix;
    zshWrapperEvaled = wlib.wrapModule zshModule;
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
    perSystem = { pkgs, self', ... }: 
    let
      zshWrapperConfig = zshWrapperEvaled.apply { 
        inherit pkgs; 
        starship = {
          enable = true;
        };
        direnv = {
          enable = true;
          package = self'.packages.direnv;
        };
        fzf = {
          enable = true;
        };
        plugins = [ 
          { 
            package = pkgs.zsh-fzf-tab; 
            name = "fzf-tab";
          }
          { 
            package = pkgs.zsh-vi-mode;
            init = "zvm_after_init_commands+=('source <(fzf --zsh)')";
          } 
          { 
            package = pkgs.oh-my-zsh;
            file = "plugins/git/git.plugin.zsh";
            disable = true;
          } 
        ];
      };
      direnvWrapperConfig = direnvWrapperEvaled.apply { 
        inherit pkgs; 
        nix-direnv.enable = true; 
      };
    in 
    {
      packages = {
        default = zshWrapperConfig.wrapper;
        direnv = direnvWrapperConfig.wrapper;
        ghd = pkgs.callPackage ./scripts/ghd {};
      };

      devShells = {
        default = import ./nix/shell.nix { inherit pkgs; };
      };
    };
  };
}
