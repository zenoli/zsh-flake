{ direnv }: 
{ pkgs, config, wlib, lib, ... }: {
  hmSessionVariables = {
    enable = lib.mkDefault true;
  };
  starship = {
    enable = lib.mkDefault true;
  };
  direnv = {
    enable = lib.mkDefault true;
    package = direnv;
  };
  fzf = {
    enable = lib.mkDefault true;
  };
  plugins = [ 
    { 
      package = pkgs.zsh-fzf-tab; 
      name = "fzf-tab";
    }
    { 
      package = pkgs.zsh-vi-mode;
      init = lib.optionalString 
        config.fzf.enable 
        "zvm_after_init_commands+=('source <(fzf --zsh)')";
    } 
    { 
      package = pkgs.oh-my-zsh;
      file = "plugins/git/git.plugin.zsh";
      disable = false;
    } 
  ];
}

