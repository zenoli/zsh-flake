{ pkgs ? import <nixpkgs> }:
pkgs.mkShell {
  name = "my-dev-shell";
  packages = with pkgs; [ jq ];
  shellHook = ''
    echo "hello from devshell"
  '';
}
