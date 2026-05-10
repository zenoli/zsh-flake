{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = import (self + /shell.nix) { inherit pkgs; };
    };
}
