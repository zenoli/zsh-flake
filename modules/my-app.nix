{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.my-app;
  createMyApp = greeting: pkgs.writeShellApplication {
    name = "my-app";
    runtimeInputs = [ pkgs.cowsay ];
    text = ''
      cowsay ${greeting}
    '';
  };


in {
  options.programs.my-app = {
    enable = mkEnableOption "My custom app";
    greeting = mkOption {
      type = types.str;
      default = "Hello!";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ (createMyApp cfg.greeting) ];
  };
}
