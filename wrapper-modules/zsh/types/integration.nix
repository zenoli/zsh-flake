{ pkgs, lib }: 
lib.types.submodule ({ config, name, ... }: {
  _file = ./integration.nix;
  freeformType = lib.types.attrsOf lib.types.anything;

  options = {
    enable = lib.mkEnableOption "${name} integration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.${name};
    };
    init = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
})

