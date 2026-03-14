{ config, lib, wlib, pkgs, ... }:
let
  cfg = config;
  direnvConfig = pkgs.symlinkJoin {
    name = "direnv-config";
    paths = [
      (pkgs.writeTextFile {
        name = "direnvrc";
        destination = "/direnvrc";
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
    env = { DIRENV_CONFIG = "${direnvConfig}"; };
  };
}
