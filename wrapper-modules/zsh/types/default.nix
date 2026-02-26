{ pkgs, lib }:
let
  files = builtins.readDir ./.;
  nixFiles =
    lib.filterAttrs
      (name: type: type == "regular" && name != "default.nix")
      files;

  stripExtension = name:
    builtins.head (builtins.match "^(.*)\\.nix$" name);

  types = lib.mapAttrs' (name: _:
    {
      name = stripExtension name;
      value = (import ./${name}) { inherit pkgs lib; };
    })
  nixFiles;
in 
  types
