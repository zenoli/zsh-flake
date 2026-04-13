{ config, wlib, lib, pkgs, ... }: 
let
  cfg = config.prompts.powerlevel10k;

in
{
  options = {
    prompts = {
      powerlevel10k = {
        enable = lib.mkEnableOption "powerlevel10k prompt";
        package = lib.mkPackageOption pkgs "zsh-powerlevel10k" {};
        "p10k.zsh" = lib.mkOption {
          type = lib.types.path;
          default = cfg.package.src + /config/p10k-lean.zsh;
        };
      };
    };
  };
  config = {
    plugins = lib.mkIf cfg.enable [
      {
        package = cfg.package;
        file = "powerlevel10k.zsh-theme";
        init = ''
        [[ ! -f ${cfg."p10k.zsh"} ]] || source ${cfg."p10k.zsh"}
        '';
      }
    ];
    snippets = {
      p10kInstantPrompt = let
        instantPrompt = ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '';
      in 
        if config.utils.hasIntegration "direnv" then
          let 
            direnvExe = lib.getExe config.integrations.direnv.package;
          in
          # See: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#how-do-i-initialize-direnv-when-using-instant-prompt
          ''
            emulate zsh -c "$(${direnvExe} export zsh)"
            ${instantPrompt}
            emulate zsh -c "$(${direnvExe} hook zsh)"
          ''
        else
          instantPrompt;
    };
  };
}
