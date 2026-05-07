{ pkgs, config, wlib, lib, ... }: {
  imports = [ ./plugins.nix ];
  prompts = {
    powerlevel10k = {
      enable = false;
      preset = "lean";
    };
    starship = {
      enable = false;
      preset = [ "pastel-powerline" ];
    };
    oh-my-posh = {
      enable = true;
      settings = {
        extends = ./omp.json;
        streaming = 40;
        blocks = [
          {
            type = "prompt";
            alignment = "left";
            segments = [
              {
                type = "path";
                options.style = "letter";
              }
            ];
          }
        ];
      };
    };
  };
  integrations = {
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

