{ pkgs, lib }: 
lib.types.submodule ({ config, name, ... }: {
  options = {
    enable = lib.mkEnableOption "${name} integration";
    init = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
})

