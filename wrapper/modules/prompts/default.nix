{ config, wlib, lib, pkgs, ... }:
let
  cfg = config.prompts;
  promptIntegrationWith = wrapperModule: wlib.types.subWrapperModuleWith {
    modules = [
      wrapperModule
      ({ name, ... }: { 
        options.enable = lib.mkEnableOption "${name} prompt";
        config.pkgs = lib.mkDefault pkgs;
      })
    ];
  };

  mkPromptIntegrationOption = wrapperModule: lib.mkOption {
    default = { 
      inherit pkgs;
      package = config.wrapper;
    };
    type = promptIntegrationWith wrapperModule;
  };
in
{
  imports = [ 
    ./powerlevel10k.nix 
    ./starship.nix 
    ./oh-my-posh.nix
  ];
  options = {
    prompts = {
      install = lib.mkOption {
        type = lib.types.raw;
        internal = true;
        readOnly = true;
        default = mkPromptIntegrationOption;
      };
    };
  };
}
