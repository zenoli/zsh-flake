{ pkgs, config, wlib, lib, ... }: {
  imports = [ ./plugins.nix ];
  integrations = {
    starship = {
      enable = lib.mkDefault true;
    };
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

