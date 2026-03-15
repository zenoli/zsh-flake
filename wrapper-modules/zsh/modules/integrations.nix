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

  wrapperInjector = { config, ...}: {
    config = { 
      inherit pkgs;
      runtimePackage = config.wrapper;
    };
  };
  
  integration = lib.types.submodule integratable;
  wrapperIntegrationWith = wrapperModule: wlib.types.subWrapperModuleWith {
    modules = [
      wrapperModule
      integratable
    ];
  };
  mkWrapperIntegrationOption = wrapperModule: lib.mkOption {
    default = { 
      inherit pkgs;
      runtimePackage = config.wrapper;
    };
    type = wrapperIntegrationWith wrapperModule;
  };



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
        freeformType = lib.types.attrsOf integration;
        options = {
          direnv = mkWrapperIntegrationOption ../../direnv.nix;
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
