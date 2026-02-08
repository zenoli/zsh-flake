{ config, lib, wlib, ... }:
let
  pkgs = config.pkgs;
  cfg = config;
in
{
  _class = "wrapper";
  options = {
    direnvrc = lib.mkOption {
      type = wlib.types.file pkgs;
      default = {
        content = "";
      };
    };
    nix-direnv = {
      enable = lib.mkEnableOption "nix-direnv integration";
      package = lib.mkPackageOption pkgs "nix-direnv" { };
    };
  };
  config = {
    package = pkgs.direnv;
    env = { DIRENV_CONFIG = "${cfg.direnvrc.path}"; };
    direnvrc = {
      content = ''
        ${lib.optionalString cfg.nix-direnv.enable ''
          source ${cfg.nix-direnv.package}/share/nix-direnv/direnvrc
        ''
        }
      '';
      # Creates a derivation "direnv-config" holding "direnvrc" as its single file:
      # direnv-config/
      #   direnvrc
      path = pkgs.writeTextFile {
        name = "direnv-config";
        destination = "/direnvrc";
        text = cfg.direnvrc.content;
      };
    };
  };
}
