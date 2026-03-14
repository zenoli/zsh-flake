{ config, wlib, lib, pkgs, ... }:
let
  types = (import ../types) { inherit pkgs lib; };

  enabledIntegrations = lib.filterAttrs (_: i: i.enable) config.integrations;
  initializableIntegrations = lib.filterAttrs (_: i: i.init != null) enabledIntegrations;

  integrationConfig = lib.concatMapAttrsStringSep 
    "\n"
    (name: integration: ''
      ## ${name} integration
      ${integration.init}
    '') initializableIntegrations;
in
{
  imports = [
    (wlib.mkInstallModule {
      name = "direnv";
      as_list = false;
      loc = [ "integrations" "direnv" "package" ];
      optLoc = [ "integrations" ];
      value = (import ../../direnv.nix);
    })
  ];
  options = {
    integrations = lib.mkOption {
      default = {};
      type = lib.types.attrsOf types.integration;
    };
  };
  config = {
    integrations = {
      fzf.init = lib.mkDefault ''source <(fzf --zsh)'';
      starship.init = ''eval "$(starship init zsh)"'';
      direnv.init = ''eval "$(direnv hook zsh)"'';
    };
    snippets.integrations = integrationConfig;
    runtimePackages = lib.mapAttrsToList (_: i : i.package) enabledIntegrations;
  };
}
