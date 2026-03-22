{ config, lib, wlib, pkgs, ... }:
let
  cfg = config;

  direnvConfig = pkgs.symlinkJoin {
    name = "direnv-config";
    paths = [
      (pkgs.writeTextFile {
        name = "direnvrc";
        destination = "/direnv.toml";
        text = cfg.direnvrc;
      })
      (lib.optional cfg.nix-direnv.enable (pkgs.writeTextFile {
        name = "direnvrc";
        destination = "/lib/nix-direnv.sh";
        text = ''
          source ${cfg.nix-direnv.package}/share/nix-direnv/direnvrc
        '';
      }))
    ];
  };
in
{
  imports = [ wlib.modules.default ];
  options = {
    configDirname = lib.mkOption {
      type = lib.types.str;
      default = "${config.binName}-dot-dir";
      description = "Name of the directory which is created as the dotdir in the wrapper output";
    };

    direnvrc = lib.mkOption {
      type = lib.types.lines;
      description = ''
        Content of $DIRENV_CONFIG/direnvrc
      '';
      default = "";
    };
    nix-direnv = {
      enable = lib.mkEnableOption "nix-direnv integration";
      package = lib.mkPackageOption pkgs "nix-direnv" { };
    };
  };
  config = {
    package = lib.mkDefault pkgs.direnv;
    env = { 
      # **IMPORTANT** DIRENV_CONFIG needs to be explicitly set in your shells environment
      # because right now, direnv will use the `direnv` binary directly in its shell 
      # hook and not the wrapper (in which $DIRENV_CONFIG got injected). 
      # Hence the wrapped config will not be picked up unless you explicitly reference 
      # this variable and set it. 
      # 
      # If the PR below will ever be merged, this issue can be fixed by setting:
      #
      # env.DIRENV_EXE_PATH = "${placeholder "out"}/bin/direnv";
      #
      # This would make the direnv hook use the wrapper instead of the original binary.
      # 
      # https://github.com/direnv/direnv/pull/1564
      DIRENV_CONFIG = "${direnvConfig}"; 
    };
    # constructfFiles = {
    #   direnvrc = {
    #     content = config.direnvrc;
    #     relPath = "${config.configDirname}/direnvrc";
    #   };
    # };
  };
}
