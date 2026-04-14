{ config, pkgs, lib, ... }: {
  plugins = with pkgs; [ 
    zsh-vi-mode
    {
      package = oh-my-zsh;
      file = "plugins/git/git.plugin.zsh";
    }
    { 
      package = zsh-fzf-tab; 
      name = "fzf-tab";
    }
    {
      package = fzf-git-sh;
      file = "fzf-git.sh";
      init = ''
        alias gc='git checkout $(_fzf_git_branches)'
      '';
    }
    zsh-syntax-highlighting
  ];
}

