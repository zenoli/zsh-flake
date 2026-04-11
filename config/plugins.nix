{ config, pkgs, lib, ... }: {
  plugins = [ 
    {
      name = "zsh-vi-mode";
      before = [ "omz-git" ];
      data = { 
        package = pkgs.zsh-vi-mode;
        init =  ''
          # ZVM_INIT_MODE=sourcing
        '';
      };
    }
    {
      name = "omz-git";
      data = { 
        package = pkgs.oh-my-zsh;
        file = "plugins/git/git.plugin.zsh";
      };
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

