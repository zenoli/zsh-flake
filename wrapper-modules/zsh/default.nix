{ config, wlib, lib, pkgs, ... }:
let
  pluginType = (import ./types/plugin.nix) { inherit lib; };
  integrationType = (import ./types/integration.nix) { inherit pkgs lib; };

  enabledPlugins = lib.filter (p: !p.disable) config.plugins;
  enabledIntegrations = lib.filterAttrs (_: i: i.enable) config.integrations;

  integrationConfigs = lib.concatMapAttrsStringSep 
    "\n"
    (name: integration: ''
      ## ${name} integration
      ${integration.init}
    '') enabledIntegrations;
  zshPluginConfigs = lib.concatMapStringsSep "\n" (
    plugin:
    builtins.concatStringsSep "\n" (
      [
        ''
          ## ${plugin.name}
          source "${plugin.src}/${plugin.file}"
        ''
      ]
      ++ (lib.optional (plugin.init != null) plugin.init
      )
    )
  ) enabledPlugins;
  zdotdir = pkgs.symlinkJoin {
    name = "zdotdir";
    paths = [ zshrc zshenv ];

  };
  zshrc = config.pkgs.writeTextFile {
    name = "zshrc";
    destination = "/.zshrc";
    text = ''
      # Sources a file relative to the src directory
      function load {
        source "${./src}/$1"
      }

      # Cleans up the environment
      function cleanup {
        unfunction load
        # unset ZDOTDIR
      }

      # Completion

      local zsh_cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      if [[ ! -d $zsh_cache_dir ]]; then
          echo "Creating $zsh_cache_dir"
          mkdir -p $zsh_cache_dir
      fi
      zcompdump_file="$zsh_cache_dir/zcompdump"

      autoload -U compinit && compinit -d $zcompdump_file


      # Plugins

      ${zshPluginConfigs}

      # Integrations

      ${integrationConfigs}

      load init.zsh

      cleanup
    '';
  };
  zshenv = config.pkgs.writeTextFile {
    name = "zshenv";
    destination = "/.zshenv";
    text = ''
      ${
        let 
          sw = config.hmSessionVariables;
        in 
          lib.optionalString sw.enable ''
            # Home Manager session variables
            [[ -f ${sw.scriptLocation} ]] && source ${sw.scriptLocation}
          ''}
      export PATH=$PATH:${pkgs.lib.makeBinPath config.runtimePackages}
    '';
  };
in
{
  imports = [ wlib.modules.default ];
  options = {
    zdotdir = lib.mkOption {
      type = lib.types.path;
      default = zdotdir;
      readOnly = true;
    };
    plugins = lib.mkOption {
      default = [ ];
      type = lib.types.listOf pluginType;
      description = "List of zsh plugins.";
    };
    runtimePackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = ''
          Additional packages added to $PATH in the wrapped .zshenv.
        '';
      };
    hmSessionVariables = {
      enable = lib.mkEnableOption "home-manager sessionVariables";
      scriptLocation = lib.mkOption {
        type = lib.types.str;
        description = ''
          Absolute path of the `hm-session-vars.sh` script to be loaded.
        '';
        default = "~/.nix-profile/etc/profile.d/hm-session-vars.sh";
      };
    };
    integrations = lib.mkOption {
      type = lib.types.attrsOf integrationType;
    };
  };
  config = {
    package = pkgs.zsh;
    integrations = {
      fzf.init = lib.mkDefault ''source <(fzf --zsh)'';
      starship.init = ''eval "$(starship init zsh)"'';
      direnv.init = ''eval "$(direnv hook zsh)"'';
    };
    runtimePackages = lib.mapAttrsToList (_: i : i.package) enabledIntegrations;
    env = {
      ZDOTDIR = "${zdotdir}";
    };
  };
}
