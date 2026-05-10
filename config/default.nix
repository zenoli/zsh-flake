{ pkgs, config, wlib, lib, ... }: {
  imports = [ ./plugins.nix ];
  prompt = "oh-my-posh";
  prompts = {
    powerlevel10k = {
      preset = "lean";
    };
    starship = {
      preset = [ "pastel-powerline" ];
    };
    oh-my-posh = {
      theme = "agnoster";
      configFile = ./omp.json;
      settings = {
        blocks = [
          {
            alignment = "left";
            type = "prompt";
            segments = [
              {
                type = "git";
                template = "boo";
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

