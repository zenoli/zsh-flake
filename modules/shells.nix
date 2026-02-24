{ self, ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = import (self + /nix/shell.nix) { inherit pkgs; };
  };
}
