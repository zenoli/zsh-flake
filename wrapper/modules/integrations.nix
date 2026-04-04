{ config, wlib, lib, pkgs, ... }:
let
  # Interface
  integratable = ({ config, name, ... }: {
    options = {
      enable = lib.mkEnableOption "${name} integration";
      package = lib.mkPackageOption pkgs name {};
      install = lib.mkOption {
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
        config.settings.pkgs = lib.mkDefault pkgs;
        config.package = lib.mkDefault config.settings.wrapper;
      })
      integratable
    ];
  };
  mkWrapperIntegrationOption = wrapperModule: lib.mkOption {
    type = wrapperIntegrationWith wrapperModule;
  };

  enabledIntegrations = lib.filterAttrs (_: i: i.enable) config.integrations;
  runtimeIntegrations = lib.filterAttrs (_: i: i.install) enabledIntegrations;
  initializableIntegrations = lib.filterAttrs (_: i: i.init != null) enabledIntegrations;

  getInitCommand = integration: 
    if lib.isFunction integration.init then 
      (integration.init (lib.getExe integration.package)) 
    else 
      integration.init;
  integrationConfig = lib.concatMapAttrsStringSep 
    "\n"
    (name: integration: ''
      ## ${name} integration
      ${getInitCommand integration}
    '') initializableIntegrations;
  direnvConfig = config.integrations.direnv;
in
{
  options = {
    integrations = lib.mkOption {
      default = {};
      type = lib.types.submodule ({ config, ...}: {
        freeformType = lib.types.attrsOf integration;
        options = {
          direnv = mkWrapperIntegrationOption wlib.wrapperModules.direnv;
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
    extraPackages' = lib.mapAttrsToList (_: i : i.package) runtimeIntegrations;
    # We need to re-define this in the context of zsh, as otherwise 
    # the direnv hook will not pick up the config wrapped inside 
    # the direnv-wrapper.
    env.DIRENV_CONFIG = lib.mkIf direnvConfig.enable direnvConfig.settings.passthru.DIRENV_CONFIG;
  };
}
