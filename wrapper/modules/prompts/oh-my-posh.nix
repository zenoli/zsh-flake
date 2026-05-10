{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.prompts;
in
{
  options = {
    prompts = {
      oh-my-posh = cfg.install wlib.wrapperModules.oh-my-posh;
    };
  };
  config = {
    integrations.oh-my-posh = {
      enable = config.prompts.oh-my-posh.enable;
      package = config.prompts.oh-my-posh.wrapper;
      init = lib.mkDefault (exe: ''eval "$(${exe} init zsh)"'');
    };
  };
}
