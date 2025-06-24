{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.zeno-zsh;
  zenoZsh = pkgs.callPackage ./zeno-zsh.nix {};


in {
  options.programs.zenoZsh = {
    enable = mkEnableOption "Zeno Zsh Config";
  };

  config = mkIf cfg.enable {
    home.packages = [ zenoZsh ];
  };
}
