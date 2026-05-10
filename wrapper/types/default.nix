{ pkgs, lib, ... }:
let
  stripExtension = name: builtins.head (builtins.match "^(.*)\\.nix$" name);
  importType = name: (import ./${name}) { inherit pkgs lib; };

  types = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (name: type: type == "regular" && name != "default.nix"))
    (lib.mapAttrs' (name: _: lib.nameValuePair (stripExtension name) (importType name)))
  ];
in
types
