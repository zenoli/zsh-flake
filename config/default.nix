{
  pkgs,
  config,
  wlib,
  lib,
  ...
}:
{
  imports = [ ./plugins.nix ];
  prompt = "powerlevel10k";
  prompts = {
    powerlevel10k = {
      "p10k.zsh" = ./src/.p10k.zsh;
    };
    starship = {
      preset = "pastel-powerline";
    };
  };
  integrations = {
    direnv = {
      enable = lib.mkDefault true;
      settings = {
        silent = true;
        nix-direnv.enable = true;
        extraConfig = {
          load_dotenv = true;
        };
      };
    };
    fzf = {
      enable = lib.mkDefault true;
    };
    kitty.enable = false;
  };
  zshSrc.directory = lib.mkDefault ./src;
}
