{
  perSystem = { pkgs, self', ... }: {
    packages.default = self'.packages.zsh;
  };
}
