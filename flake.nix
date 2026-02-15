{
  description = ''
    Uses flake-parts to set up the flake outputs:

    `wrappers`, `wrapperModules` and `packages.*.*`
  '';
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      wrappers,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, withSystem, ... }: {
      systems = nixpkgs.lib.platforms.all;
      imports = [ wrappers.flakeModules.wrappers ];
      perSystem = { pkgs, self', ... }:
        {
          packages.default = self'.packages.zsh;
          devShells.default = import ./nix/shell.nix { inherit pkgs; };
        };
      flake = {
        homeManagerModules = {
          zsh = inputs.wrappers.lib.mkInstallModule {
            loc = [ "home" "packages" ];
            name = "zsh";
            value = config.flake.wrapperModules.zsh;
          };
        };
        wrappers = {
          direnv = { pkgs, wlib, ... }: {
            imports = [ (import ./direnv.nix) ];
            nix-direnv.enable = true;
          };
          zsh = { pkgs, wlib, ... }: {
            imports = [ (import ./zeno-zsh.nix) ];
            starship = {
              enable = true;
            };
            direnv = {
              enable = true;
              package = withSystem pkgs.stdenv.hostPlatform.system (
                  { config, ... }: # perSystem module arguments
                  config.packages.direnv
                );
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
                disable = false;
              } 
            ];
          };
        };
      };
    });
}
