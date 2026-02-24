{ self, inputs, ... }: {
  flake.homeManagerModules = {
    zsh = inputs.wrappers.lib.mkInstallModule {
      loc = [ "home" "packages" ];
      name = "zsh";
      value = self.wrapperModules.zsh;
    };
  };
}
