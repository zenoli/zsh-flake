{ self, withSystem, ... }: {
  flake.wrappers = {
    direnv = { pkgs, wlib, ... }: {
      imports = [ (import (self + /wrapper-modules/direnv.nix)) ];
      nix-direnv.enable = true;
    };
    zsh = { pkgs, wlib, lib, ... }: 
    let
      direnvWrapper = withSystem pkgs.stdenv.hostPlatform.system (
        { config, ... }: config.packages.direnv
      );
      zshWrapperModule = import (self + /wrapper-modules/zsh);
      zshWrapperConfig = import (self + /config.nix) { direnv = direnvWrapper; };
    in 
    {
      imports = [ 
        zshWrapperModule
        zshWrapperConfig
      ];
    };
  };
}
