{ pkgs ? import <nixpkgs> }:
let 
  foo = pkgs.callPackage ../packages/foo {};
in
  pkgs.mkShell {
    name = "my-dev-shell";
    packages = with pkgs; [ jq antidote ];
    shellHook = ''
      echo "hello from devshell"
    '';
  }
