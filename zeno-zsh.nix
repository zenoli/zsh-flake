{ config, wlib, lib, pkgs, ... }:
let
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
        source ${./src}/$1
      }

      # Cleans up the environment
      function cleanup {
        unfunction load
        # unset ZDOTDIR
      }

      # Completion

      local zsh_cache_dir="$XDG_CACHE_HOME/zsh"
      if [[ ! -d $zsh_cache_dir ]]; then
          echo "Creating $zsh_cache_dir"
          mkdir -p $zsh_cache_dir
      fi
      zcompdump_file="$zsh_cache_dir/zcompdump"

      autoload -U compinit && compinit -d $zcompdump_file


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
  };
  zshenv = config.pkgs.writeTextFile {
    name = "zshenv";
    destination = "/.zshenv";
    text = ''
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
      type = lib.types.listOf zshPluginType;
      description = "List of zsh plugins.";
    };
    runtimePackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = ''
          Additional packages added to $PATH in the wrapped .zshenv.
        '';
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
    package = pkgs.zsh;
    runtimePackages = with pkgs; 
      [ cowsay ]
      ++ lib.optional config.starship.enable config.starship.package
      ++ lib.optional config.direnv.enable config.direnv.package
      ++ lib.optional config.fzf.enable config.fzf.package;
    env = {
      ZDOTDIR = "${zdotdir}";
    };
  };
}
