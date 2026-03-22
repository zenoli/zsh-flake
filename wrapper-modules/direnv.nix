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
    # package = lib.mkDefault pkgs.direnv;
    package = pkgs.direnv.overrideAttrs (old: {
      src = /home/olivier/repos/direnv;
    });
    env = { 
      DIRENV_CONFIG = "${direnvConfig}"; 
      DIRENV_EXE_PATH = "${placeholder "out"}/bin/direnv";
    };
    # constructfFiles = {
    #   direnvrc = {
    #     content = config.direnvrc;
    #     relPath = "${config.configDirname}/direnvrc";
    #   };
    # };
  };
}
