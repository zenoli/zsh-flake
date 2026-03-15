{ pkgs, config, wlib, lib, ... }: {
  hmSessionVariables = {
    enable = lib.mkDefault true;
  };
  integrations = {
    starship = {
      enable = lib.mkDefault true;
      package = pkgs.starship;
    };
    direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = lib.mkDefault true;
      package = pkgs.fzf;
    };
  };
  plugins = [ 
    { 
      package = pkgs.zsh-fzf-tab; 
      name = "fzf-tab";
    }
    { 
      package = pkgs.zsh-vi-mode;
      init = lib.optionalString 
        config.integrations.fzf.enable 
        "zvm_after_init_commands+=('source <(fzf --zsh)')";
    } 
    { 
      package = pkgs.oh-my-zsh;
      file = "plugins/git/git.plugin.zsh";
      disable = false;
    } 
  ];
}

