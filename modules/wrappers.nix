{ self, withSystem, ... }: {
  flake.wrappers = {
    direnv = { pkgs, wlib, ... }: {
      imports = [ (import ../wrapper-modules/direnv.nix) ];
      nix-direnv.enable = true;
    };
    zsh = { pkgs, wlib, lib, ... }: {
      imports = [ (import ../wrapper-modules/zsh) ];
      hmSessionVariables = {
        enable = lib.mkDefault true;
      };
      starship = {
        enable = lib.mkDefault true;
      };
      direnv = {
        enable = lib.mkDefault true;
        package = withSystem pkgs.stdenv.hostPlatform.system (
          { config, ... }: config.packages.direnv
        );
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
            self.wrappers.zsh.fzf.enable 
            "zvm_after_init_commands+=('source <(fzf --zsh)')";
        } 
        { 
          package = pkgs.oh-my-zsh;
          file = "plugins/git/git.plugin.zsh";
          disable = false;
        } 
      ];
    };
  };
}
