{ config, wlib, lib, pkgs, ... }:
let
  # Interface
  integratable = ({ config, name, ... }: {
    options = {
      enable = lib.mkEnableOption "${name} integration";
      runtimePackage = lib.mkPackageOption pkgs name {};
      addToPath = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      init = lib.mkOption {
        type = lib.types.nullOr (lib.types.either 
          lib.types.str 
          (lib.types.functionTo lib.types.str) # exe: string
        );
        default = null;
      };
    };
  });

  integration = lib.types.submodule integratable;
  wrapperIntegrationWith = wrapperModule: lib.types.submoduleWith {
    modules = [
      ({config, ... }: {
        options.settings = lib.mkOption {
          type = wlib.types.subWrapperModule wrapperModule;
        };
        config.settings.pkgs = pkgs;
        config.runtimePackage = config.settings.wrapper;
      })
      integratable
    ];
  };
  mkWrapperIntegrationOption = wrapperModule: lib.mkOption {
    # default = { 
    #   settings.pkgs = pkgs;
    #   runtimePackage = config.settings.wrapper;
    # };
    type = wrapperIntegrationWith wrapperModule;
  };



  enabledIntegrations = lib.filterAttrs (_: i: i.enable) (builtins.trace (builtins.attrNames config.integrations) config.integrations);
  runtimeIntegrations = lib.filterAttrs (_: i: i.addToPath) enabledIntegrations;
  initializableIntegrations = lib.filterAttrs (_: i: i.init != null) enabledIntegrations;

  getInitCommand = integration: 
    if lib.isFunction integration.init then 
      (integration.init (lib.getExe integration.runtimePackage)) 
    else 
      integration.init;
  integrationConfig = lib.concatMapAttrsStringSep 
    "\n"
    (name: integration: ''
      ## ${name} integration
      ${getInitCommand integration}
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
    integrations =  {
      # Preset init commands
      fzf.init = lib.mkDefault (exe: ''source <(${exe} --zsh)'');
      starship.init = lib.mkDefault (exe: ''eval "$(${exe} init zsh)"'');
      direnv.init = lib.mkDefault (exe: ''eval "$(${exe} hook zsh)"'');
    };
    snippets.integrations = integrationConfig;
    runtimePackages = lib.mapAttrsToList (_: i : i.runtimePackage) runtimeIntegrations;
  };
}
