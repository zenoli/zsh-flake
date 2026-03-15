{ config, wlib, lib, pkgs, ... }:
let
  types = (import ../types) { inherit pkgs lib; };

  enabledIntegrations = lib.filterAttrs (_: i: i.enable) (builtins.trace (builtins.attrNames config.integrations) config.integrations);
  initializableIntegrations = lib.filterAttrs (_: i: i.init != null) enabledIntegrations;

  integrationConfig = lib.concatMapAttrsStringSep 
    "\n"
    (name: integration: ''
      ## ${name} integration
      ${integration.init}
    '') initializableIntegrations;
in
{
  options = {
    integrations = lib.mkOption {
      default = {};
      type = lib.types.submodule ({ config, ...}: {
        freeformType = lib.types.attrsOf types.integration;
        options = {
          direnv = lib.mkOption {
            default = {};
            type = wlib.types.subWrapperModule (
              (lib.toList ../../direnv.nix)
              ++ [
                ({ config, ...}: {
                  options.enable = lib.mkEnableOption "direnv integration";
                  options.init = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                  };
                  options.useWrapper = lib.mkOption {
                    type = lib.types.boolean;
                    default = true;
                  };
                  # config.package = config.wrapper;
                  options.runtimePackage = lib.mkOption {
                    type = lib.types.package;
                    default = config.wrapper;
                  };
                  config = { inherit pkgs; };
                })
              ]
            );
          };
        };
      });
    };
  };
  config = {
    integrations = {
      fzf.init = lib.mkDefault ''source <(fzf --zsh)'';
      starship.init = ''eval "$(starship init zsh)"'';
      direnv.init = ''eval "$(direnv hook zsh)"'';
    };
    snippets.integrations = integrationConfig;
    # runtimePackages = lib.mapAttrsToList (_: i : i.package) enabledIntegrations;
    runtimePackages = lib.mapAttrsToList (_: i:
      if builtins.hasAttr "wrapper" i then i.runtimePackage else i.package
    ) enabledIntegrations;
  };
}
