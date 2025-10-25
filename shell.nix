{ pkgs ? import <nixpkgs> }:
let
  # Function to create script
  mkScript = name: text: let
    script = pkgs.writeShellScriptBin name text;
  in script;
  
  # Define your scripts/aliases
  scripts = [
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
  packages = with pkgs; [ jq ] ++ scripts;
}

