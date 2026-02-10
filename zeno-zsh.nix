{ config, wlib, lib, ... }:
let
  pkgs = config.pkgs;
  zshPluginType = lib.types.submodule ({config, ... } :{
    options = {
      plugin = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
      };
      src = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to the plugin folder.

          Will be added to {env}`fpath` and {env}`PATH`.
        '';
        default = config.plugin.src;
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = if config.plugin != null 
        then config.plugin.pname
        else throw "Plugin option 'name' must be provided if 'plugin' is null.";
      };
      file = lib.mkOption {
        type = lib.types.str;
        default = "${config.name}.plugin.zsh";
      };
      init = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  });
  pluginSpecs = [
    {
      name = "fzf-tab";
      plugin = pkgs.zsh-fzf-tab;
    }
    rec {
      name = "zsh-vi-mode";
      plugin = pkgs.zsh-vi-mode;
      config = ''
        zvm_after_init_commands+=('source <(fzf --zsh)')
      '';
    }
  ];
  zshPlugins = lib.concatMapStringsSep "\n" (
    spec:
    builtins.concatStringsSep "\n" (
      [
        ''
          ##########################
          ## ${spec.name}
          ##########################
          source ${spec.plugin.src}/${spec.name}.plugin.zsh
        ''
      ]
      ++ (lib.optionals (builtins.hasAttr "config" spec) [
        "# Config"
        spec.config
      ])
    )
  ) pluginSpecs;
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

      ${zshPlugins}

      echo ${(lib.head config.plugins).name}
      echo ${(lib.head config.plugins).file}

      ${lib.optionalString config.starship.enable ''
        # Starship integration
        eval "$(starship init zsh)"
      ''}
      ${lib.optionalString config.direnv.enable ''
        # Direnv integration
        eval "$(direnv hook zsh)"
      ''}
      ${lib.optionalString config.fzf.enable ''
        # Fzf integration
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
    # plugins = [ { plugin = pkgs.zsh-vi-mode;} ];
    plugins = [ { name = "my-name"; file = "my-file.sh"; src = pkgs.zsh-vi-mode.src;} ];
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
