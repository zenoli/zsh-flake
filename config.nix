{ pkgs, config, wlib, lib, ... }: {
  # hmSessionVariables = {
  #   enable = lib.mkDefault true;
  # };
  integrations = {
    starship = {
      enable = lib.mkDefault true;
    };
    direnv = {
      enable = lib.mkDefault true;
      settings = {
        nix-direnv.enable = true;
      };
    };
    fzf = {
      enable = lib.mkDefault true;
    };
    hello = {
      enable = true;
      install = true;
      init = exe: "${exe} -g 'olivier'";
    };

  };
  # extraPackages = [ pkgs.oh-my-zsh ];
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
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      # src = builtins.trace "${pkgs.oh-my-zsh.src}" pkgs.oh-my-zsh.src;
      file = "plugins/git/git.plugin.zsh";
      disable = false;
    } 
  ];
}

