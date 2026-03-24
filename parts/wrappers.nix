{ self, withSystem, ... }: {
  flake.wrappers = {
    direnv = { pkgs, wlib, ... }: {
      imports = [ wlib.wrapperModules.direnv ];
      nix-direnv.enable = true;
      silent = true;
    };
    zsh = { pkgs, wlib, lib, ... }: 
    let
      zshWrapperModule = import (self + /wrapper-modules/zsh);
      zshWrapperConfig = import (self + /config.nix);
    in 
    {
      imports = [ 
        zshWrapperModule
        zshWrapperConfig
      ];
    };
  };
}
