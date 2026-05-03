{ pkgs, config, wlib, lib, ... }: {
  imports = [ ./plugins.nix ];
  prompts = {
    powerlevel10k = {
      enable = false;
      preset = "lean";
    };
    starship = {
      enable = true;
      preset = [ "pastel-powerline" ];
    };
  };
  integrations = {
    direnv = {
      enable = lib.mkDefault true;
      settings = {
        silent = true;
        nix-direnv.enable = true;
      };
    };
    fzf = {
      enable = lib.mkDefault true;
    };
  };
  zshSrc.directory = lib.mkDefault ./src;
}

