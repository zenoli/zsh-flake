{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.my-app;
  myApp = pkgs.writeShellApplication {
    name = "my-app";
    runtimeInputs = [ pkgs.cowsay ];
    text = ''
      cowsay foo
    '';
  };


in {
  options.programs.my-app = {
    enable = mkEnableOption "My custom app";
  };

  config = mkIf cfg.enable {
    home.packages = [ myApp ];
  };
}
