{
  perSystem = { pkgs, self', ... }: {
    devShells.default = import ../nix/shell.nix { inherit pkgs; };
  };
}
