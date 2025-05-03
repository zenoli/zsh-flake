{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.myApp;
  myApp = pkgs.callPackage ../packages/my-app.nix { greeting = cfg.greeting; };
in {
  options.programs.myApp = {
    enable = mkEnableOption "My custom app";
    greeting = mkOption {
      type = types.str;
      default = "Hello!";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ myApp ];
  };
}
