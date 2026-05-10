{ self, inputs, ... }:
{
  flake.nixosModules = {
    zsh = inputs.wrappers.lib.mkInstallModule {
      name = "zsh";
      value = self.wrapperModules.zsh;
    };
  };
}
