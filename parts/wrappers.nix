{ self, withSystem, ... }:
{
  flake.wrappers = {
    direnv =
      { pkgs, wlib, ... }:
      {
        imports = [ wlib.wrapperModules.direnv ];
        nix-direnv.enable = true;
        silent = true;
      };
    zsh = {
      imports = [
        (self + /wrapper)
        (self + /config)
      ];
    };
  };
}
