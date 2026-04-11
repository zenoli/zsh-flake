{ pkgs ? import <nixpkgs> }:
let
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
  packages = with pkgs; [ ] ++ scripts;
}
