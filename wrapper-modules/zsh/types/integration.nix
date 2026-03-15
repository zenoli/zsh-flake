{ pkgs, lib }: 
lib.types.submodule ({ config, name, ... }: {
  # freeformType = lib.types.attrsOf lib.types.anything;

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
    settings = lib.mkOption {
      type = lib.types.anything;
      default = null;
    };
  };
})

