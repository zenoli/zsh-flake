{ self, inputs, ... }: {
  flake.homeModules = {
    zsh = inputs.wrappers.lib.mkInstallModule {
      loc = [ "home" "packages" ];
      name = "zsh";
      value = self.wrapperModules.zsh;
    };
  };
}
