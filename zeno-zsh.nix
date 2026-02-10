{ config, wlib, lib, ... }:
let
  pkgs = config.pkgs;
  zshPluginType = lib.types.submodule ({config, ... } :{
    options = {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
      };
      src = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to the plugin folder.

          Will be added to {env}`fpath` and {env}`PATH`.
        '';
        default = config.package.src;
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = if config.package != null 
        then config.package.pname
        else throw "Plugin option 'name' must be provided if 'package' is null.";
      };
      file = lib.mkOption {
        type = lib.types.str;
        default = "${config.name}.plugin.zsh";
      };
      init = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      disable = lib.mkOption {
        default = false;
        example = true;
        description = "Whether to disable plugin ${config.name}.";
        type = lib.types.bool;
      };
    };
  });
  enabledPlugins = lib.filter (plugin: !plugin.disable) config.plugins;
  zshPluginConfigs = lib.concatMapStringsSep "\n" (
    plugin:
    builtins.concatStringsSep "\n" (
      [
        ''
          ## ${plugin.name}
          source ${plugin.src}/${plugin.file}
        ''
      ]
      ++ (lib.optional (plugin.init != null) plugin.init
      )
    )
  ) enabledPlugins;
  zdotdir = config.pkgs.writeTextFile {
    name = "zdotdir";
    text = ''
      # Sources a file relative to the src directory
      function load {
        source ${./src}/$1
      }

      # Cleans up the environment
      function cleanup {
        unfunction load
        # unset ZDOTDIR
      }

      # Plugins

      ${zshPluginConfigs}

      # Integrations

      ${lib.optionalString config.starship.enable ''
        ## Starship integration
        eval "$(starship init zsh)"
      ''}
      ${lib.optionalString config.direnv.enable ''
        ## Direnv integration
        eval "$(direnv hook zsh)"
      ''}
      ${lib.optionalString config.fzf.enable ''
        ## Fzf integration
        source <(fzf --zsh)
      ''}

      load init.zsh

      cleanup
    '';
    destination = "/.zshrc";
  };
in
{
  _class = "wrapper";
  options = {
    plugins = lib.mkOption {
      default = [ ];
      type = lib.types.listOf zshPluginType;
      description = "List of zsh plugins.";
    };
    direnv = {
      enable = lib.mkEnableOption "direnv integration";
      package = lib.mkPackageOption pkgs "direnv" { };
    };
    fzf = {
      enable = lib.mkEnableOption "fzf integration";
      package = lib.mkPackageOption pkgs "fzf" { };
    };
    starship = {
      enable = lib.mkEnableOption "starship integration";
      package = lib.mkPackageOption pkgs "starship" { };
    };
  };
  config = {
    plugins = [ 
      { 
        package = pkgs.zsh-fzf-tab; 
        name = "fzf-tab";
      }
      { 
        package = pkgs.zsh-vi-mode;
        init = (
          if config.fzf.enable
          then "zvm_after_init_commands+=('source <(fzf --zsh)')" 
          else null
        );
      } 
    ];
    package = pkgs.zsh;
    extraPackages = with pkgs; 
      [ cowsay ] 
      ++ lib.optional config.starship.enable config.starship.package
      ++ lib.optional config.direnv.enable config.direnv.package
      ++ lib.optional config.fzf.enable config.fzf.package;
    env = {
      ZDOTDIR = "${zdotdir}";
    };
  };
}
