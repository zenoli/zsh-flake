{ config, wlib, lib, ... }:
let
  pkgs = config.pkgs;
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

      ${lib.optionalString config.direnv.enable ''
        eval "$(direnv hook zsh)"
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
    direnv = {
      enable = lib.mkEnableOption "direnv integration";
      package = lib.mkPackageOption pkgs "direnv" { };
    };
    fzf = {
      enable = lib.mkEnableOption "fzf integration";
      package = lib.mkPackageOption pkgs "fzf" { };
    };
  };
  config = {
    package = pkgs.zsh;
    extraPackages = with pkgs; 
      [ starship cowsay ] 
      ++ lib.optional config.direnv.enable config.direnv.package
      ++ lib.optional config.fzf.enable fzf;
    env = {
      ZDOTDIR = "${zdotdir}";
    };
  };
}
