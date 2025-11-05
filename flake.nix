{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers.url = "github:lassulus/wrappers";
    wrapper-manager.url = "github:viperML/wrapper-manager";
  };

  outputs = { self, nixpkgs, home-manager, wrappers, wrapper-manager }: 
  let
    util = import ./nix/util.nix { inherit nixpkgs; };
    loadModule = moduleFn:
    (moduleFn { 
      wlib = wrappers.lib; 
      lib = nixpkgs.lib; 
    });
    applyWrapperModule = moduleFn: pkgs: args:
      ((loadModule moduleFn).apply ({ inherit pkgs; } // args)).wrapper;
    evalWrapperConfig = moduleFn: pkgs: args:
      ((loadModule moduleFn).apply ({ inherit pkgs; } // args));
  in 
  {
    packages = util.forAllSystems (pkgs: 
    let 
      wm-eval = wrapper-manager.lib {
        inherit pkgs;
        modules = [ ./zeno-zsh3.nix ];
      };
    in
    {
      default = pkgs.callPackage ./zeno-zsh.nix {};
      ghd = pkgs.callPackage ./scripts/ghd {};
      zsh2 = applyWrapperModule (import ./zeno-zsh2.nix) pkgs { direnv = false; };
      zsh3 = wm-eval.config.wrappers.zsh.wrapped;
      zsh4 = wrapper-manager.lib.wrapWith pkgs (import ./zeno-zsh4.nix);

    });

    devShells = util.forAllSystems (pkgs: {
      default = import ./nix/shell.nix { inherit pkgs; };
    });

    zshConfig = evalWrapperConfig (import ./zeno-zsh2.nix) nixpkgs.legacyPackages."x86_64-linux" ./zsh-config.nix;

    homeManagerModules.zenoZsh = (import ./zeno-zsh-module.nix);
  };
}
