{ config, wlib, lib, pkgs, ... }:
let
  types = (import ../types) { inherit pkgs lib; };

  integratable = ({ config, name, ... }: {
    options = {
      enable = lib.mkEnableOption "${name} integration";
      runtimePackage = lib.mkPackageOption pkgs name {};
      init = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  });


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
        freeformType = lib.types.attrsOf (lib.types.submodule integratable);
        options = {
          direnv = lib.mkOption {
            default = {};
            type = wlib.types.subWrapperModule (
              (lib.toList ../../direnv.nix)
              ++ [
                integratable
                ({ config, ...}: {
                  config = { 
                    inherit pkgs;
                    runtimePackage = config.wrapper;
                  };
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
    runtimePackages = lib.mapAttrsToList (_: i : i.runtimePackage) enabledIntegrations;
  };
}
