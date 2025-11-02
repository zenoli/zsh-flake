{ nixpkgs }:
let
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "i686-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
in 
{
  forAllSystems = function:
    nixpkgs.lib.genAttrs 
      systems 
      (system: function nixpkgs.legacyPackages.${system});
}
