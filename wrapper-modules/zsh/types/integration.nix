{ pkgs, lib }: 
lib.types.submodule ({ config, name, ... }: {
  options = {
    enable = lib.mkEnableOption "${name} integration";
    runtimePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.${name};
    };
    init = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
})

