{ wlib, lib }:
wlib.wrapModule (
  { config, wlib, ... }:
  let
    pkgs = config.pkgs;
    cfg = config;
  in
  {
    options = {
      direnvrc = lib.mkOption {
        type = wlib.types.file pkgs;
        default = {
          content = "";
        };
      };
    };
    config = {
      package = pkgs.direnv;
      env = { DIRENV_CONFIG = "${cfg.direnvrc.path}/direnv"; };
      direnvrc = {
        content = ''
          source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
        '';
        path = pkgs.writeTextDir "direnv/direnvrc" cfg.direnvrc.content;
      };
    };
  }
)
