{ lib, ... }:
let
  modules = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (name: type: type == "regular" && name != "default.nix"))
    (lib.mapAttrsToList (name: _: ./${name}))
  ];
in 
{
  imports = modules;
}
