{ config, pkgs, lib, ... }: {
  prompts.powerlevel10k.enable = true;
  plugins = [ 
    { 
      package = pkgs.zsh-vi-mode;
      init =  ''
        # ZVM_INIT_MODE=sourcing
      '';
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
    {
      package = pkgs.zsh-syntax-highlighting;
    }
  ];
}

