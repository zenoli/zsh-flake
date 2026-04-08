{ config, pkgs, lib, ... }: {
  plugins = [ 
    { 
      package = pkgs.zsh-vi-mode;
      init = lib.optionalString 
        config.integrations.fzf.enable 
        "zvm_after_init_commands+=('source <(fzf --zsh)')";
    } 
    { 
      package = pkgs.oh-my-zsh;
      file = "plugins/git/git.plugin.zsh";
    } 
    { 
      package = pkgs.zsh-fzf-tab; 
      name = "fzf-tab";
    }
    {
      package = pkgs.fzf-git-sh;
      file = "fzf-git.sh";
      init = ''
        alias gc='git checkout $(_fzf_git_branches)'
      '';
    }
  ];
}

