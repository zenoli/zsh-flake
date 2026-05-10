{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.default = self'.packages.zsh;
      packages.p10k-configure = pkgs.callPackage ../scripts/p10k-configure.nix { };
    };
}
