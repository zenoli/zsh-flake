{ config, wlib, lib, pkgs, ... }:
{
  options = {
    completion = {
      enable = lib.mkEnableOption "zsh completion";
      init = lib.mkOption {
        type = lib.types.str;
        default = ''
          # completion

          local zsh_cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
          if [[ ! -d $zsh_cache_dir ]]; then
              echo "Creating $zsh_cache_dir"
              mkdir -p $zsh_cache_dir
          fi
          zcompdump_file="$zsh_cache_dir/zcompdump"
          autoload -U compinit && compinit -d $zcompdump_file
        '';
      };
    };
  };
  config.completion.enable = lib.mkDefault true;
}
