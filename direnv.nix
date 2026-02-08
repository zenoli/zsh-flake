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
        path = pkgs.symlinkJoin {
          name = "direnv-config";
          paths = [
            (pkgs.writeTextFile {
              name = "direnvrc";
              destination = "/direnvrc";
              text = cfg.direnvrc.content;
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
  };
}
