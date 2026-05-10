{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.prompts;

  prompts = [
    "oh-my-posh"
    "powerlevel10k"
    "starship"
  ];
  promptIntegrationWith =
    wrapperModule:
    wlib.types.subWrapperModuleWith {
      modules = [
        wrapperModule
        (
          { name, ... }:
          {
            options.enable = lib.mkEnableOption "${name} prompt";
            config.pkgs = lib.mkDefault pkgs;
          }
        )
      ];
    };

  mkPromptIntegrationOption =
    wrapperModule:
    lib.mkOption {
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
    prompt = lib.mkOption {
      type = with lib.types; nullOr (enum prompts);
      default = null;
      description = ''
        The currently active prompt.
        This option provides a convenient way to switch prompts without having
        to enable/disable them in two places.
        If you use this option (i.e. have it set to a valid string) you must
        not define any `.enable` option inside `config.prompts` as they will 
        conflict with this option.
      '';
    };
    prompts = {
      install = lib.mkOption {
        type = lib.types.raw;
        internal = true;
        readOnly = true;
        default = mkPromptIntegrationOption;
      };
    };
  };
  config.prompts = lib.mkIf (config.prompt != null) (
    lib.genAttrs prompts (name: {
      enable = name == config.prompt;
    })
  );
}
