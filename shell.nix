{ pkgs ? import <nixpkgs> }:
let
  lib = pkgs.lib;
  # Function to create script
  mkScript = name: text: let
    script = pkgs.writeShellScriptBin name text;
  in script;

  # Define your scripts/aliases
  scripts = [
    (pkgs.callPackage ./scripts/ghd {})
    (pkgs.writeShellApplication {
      name = "debug-zshrc";
      runtimeInputs = with pkgs; [ neovim ];
      text = ''
        nix build && nvim result/zsh-dot-dir/.zshrc
      '';
    })
    (pkgs.writeShellApplication {
      name = "debug-zshenv";
      runtimeInputs = with pkgs; [ neovim ];
      text = ''
        nix build && nvim result/zsh-dot-dir/.zshenv
      '';
    })
    (pkgs.writeScriptBin "p10k-configure" ''
      #!/usr/bin/env -S ${lib.getExe pkgs.zsh} -i
      ZDOTDIR=$(${lib.getExe pkgs.mktemp} -d --tmpdir zdotdir-XXXXXXXXXX)
      export ZDOTDIR
      source ${pkgs.zsh-powerlevel10k.src}/powerlevel10k.zsh-theme
      p10k configure
      read "move?Move $ZDOTDIR/.p10k.zsh? [y/n] "
      if [[ $move == y ]]; then
        dest=.
        vared -p "Destination directory: " dest
        mv "$ZDOTDIR/.p10k.zsh" "$dest/.p10k.zsh"
        echo "Moved to $dest/.p10k.zsh"
        rm -rf "$ZDOTDIR"
        echo "Removed $ZDOTDIR"
      else
        echo ".p10k.zsh was created at:"
        echo "$ZDOTDIR/.p10k.zsh"
      fi
      echo Done!
    '')
    (pkgs.writeShellApplication {
      name = "dev";
      runtimeInputs = with pkgs; [ watchexec ];
      text = ''
        watchexec \
          --restart \
          --clear \
          --stop-signal=SIGHUP \
          --stop-timeout=1s \
          --wrap-process=none \
          nix run
      '';
    })
  ];
in 
pkgs.mkShell {
  packages = with pkgs; [ zsh-powerlevel10k ] ++ scripts;
}
