{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.completion;
in
{
  options = {
    completion = {
      enable = lib.mkEnableOption "zsh completion";
      init = lib.mkOption {
        type = lib.types.str;
        default = ''
          local zsh_cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
          if [[ ! -d $zsh_cache_dir ]]; then
              echo "Creating $zsh_cache_dir"
              mkdir -p $zsh_cache_dir
          fi
          zcompdump_file="$zsh_cache_dir/zcompdump"
          autoload -U compinit
          # The full fpath scan + security audit is slow, so only do it once a day
          # and otherwise trust the cached dump (-C).
          local -a stale_zcompdump=($zcompdump_file(N.mh+24))
          if (( $#stale_zcompdump )); then
              compinit -d $zcompdump_file && touch $zcompdump_file
          else
              compinit -C -d $zcompdump_file
          fi
          unset stale_zcompdump
        '';
      };
    };
  };
  config.completion.enable = lib.mkDefault true;
  config.snippets.completion = lib.optionalString cfg.enable cfg.init;
}
