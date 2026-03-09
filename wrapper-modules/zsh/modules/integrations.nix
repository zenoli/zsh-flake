{ config, wlib, lib, pkgs, ... }:
let
  types = (import ../types) { inherit pkgs lib; };
  enabledIntegrations = lib.filterAttrs (_: i: i.enable) config.integrations;
  integrationConfig = lib.concatMapAttrsStringSep 
    "\n"
    (name: integration: ''
      ## ${name} integration
      ${integration.init}
    '') enabledIntegrations;
in
{
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
