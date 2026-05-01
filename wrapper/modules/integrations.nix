{ config, wlib, lib, pkgs, ... }@top:
let
  enabledIntegrations = lib.filter (i: i.enable) (wlib.dag.sortAndUnwrap { dag = config.integrations; });
  runtimeIntegrations = lib.filter (i: i.install) enabledIntegrations;
  initializableIntegrations = lib.filter (i: i.init != null) enabledIntegrations;

  wrapperIntegrationWith = wrapperModule: lib.types.submoduleWith {
    modules = [
      ({config, ... }: {
        options.settings = lib.mkOption {
          type = wlib.types.subWrapperModule wrapperModule;
        };
        config.settings.pkgs = lib.mkDefault pkgs;
        config.package = lib.mkDefault config.settings.wrapper;
      })
      config.interfaces.integratable
      config.interfaces.sortable
    ];
  };
  mkWrapperIntegrationOption = wrapperModule: lib.mkOption {
    type = wrapperIntegrationWith wrapperModule;
  };

  getInitCommand = integration: 
    if lib.isFunction integration.init then 
      (integration.init (lib.getExe integration.package)) 
    else 
      integration.init;
  integrationConfig = lib.concatMapStringsSep 
    "\n"
    (integration: ''
      ## ${lib.getName integration.package} integration
      ${getInitCommand integration}
    '') initializableIntegrations;
  direnvConfig = config.integrations.direnv;
in
{
  options = {
    integrations = lib.mkOption {
      default = {};
      type = lib.types.submodule ({ config, ...}: {
        freeformType = with lib.types; attrsOf (submodule top.config.interfaces.integratable);
        options = {
          direnv = mkWrapperIntegrationOption wlib.wrapperModules.direnv;
          starship = mkWrapperIntegrationOption wlib.wrapperModules.starship;
        };
      });
    };
    utils.hasIntegration = lib.mkOption {
      type = lib.types.functionTo lib.types.bool;
      internal = true;
      readOnly = true;
      default = name: lib.elem name (lib.pipe enabledIntegrations [
        # lib.attrValues
        (lib.map (p: lib.getName p.package))
      ]);
    };
  };
  config = {
    integrations =  {
      # Preset init commands
      fzf.init = lib.mkDefault (exe:
        let 
          initCmd = ''source <(${exe} --zsh)''; 
        in
          if (config.utils.hasPlugin "zsh-vi-mode") then
            ''zvm_after_init_commands+=('${initCmd}')''
          else
            initCmd
      );
      # fzf.init = builtins.trace zshViModeInstalled (lib.mkDefault (exe: ''source <(${exe} --zsh)''));
      starship.init = lib.mkDefault (exe: ''eval "$(${exe} init zsh)"'');
      # TODO: Only set init if powerlevel10k is enabled and direnv is enabled
      direnv.init = lib.mkIf (!config.prompts.powerlevel10k.enable)
        (lib.mkDefault (exe: ''eval "$(${exe} hook zsh)"''));

    };
    snippets.integrations = integrationConfig;
    extraPackages' = lib.map (i : i.package) runtimeIntegrations;
    # We need to re-define this in the context of zsh, as otherwise 
    # the direnv hook will not pick up the config wrapped inside 
    # the direnv-wrapper.
    env.DIRENV_CONFIG = lib.mkIf direnvConfig.enable direnvConfig.settings.passthru.DIRENV_CONFIG;
  };
}
