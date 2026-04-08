{ pkgs, config, wlib, lib, ... }: {
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
  plugins = [ 
    { 
      package = pkgs.zsh-vi-mode;
      init = lib.optionalString 
        config.integrations.fzf.enable 
        "zvm_after_init_commands+=('source <(fzf --zsh)')";
      disable = false;
    } 
    { 
      package = pkgs.oh-my-zsh;
      file = "plugins/git/git.plugin.zsh";
      disable = false;
    } 
    { 
      package = pkgs.zsh-fzf-tab; 
      name = "fzf-tab";
    }
  ];
  zshSrc.directory = lib.mkDefault ./src;
}

