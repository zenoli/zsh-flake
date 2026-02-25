{ pkgs, lib }: 
lib.types.submodule ({ config, name, ... }: {
  options = {
    enable = lib.mkEnableOption "${name} integration";
    package = lib.mkPackageOption pkgs name {};
    init = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
})

