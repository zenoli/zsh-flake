{ lib, ... }: 
lib.types.submodule ({ config, ... }: {
  options = {
    package = lib.mkOption {
      type = lib.types.package;
    };
    src = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the plugin folder.
      '';
      default = config.package.src;
    };
    name = lib.mkOption {
      type = lib.types.str;
      default = config.package.pname;
    };
    file = lib.mkOption {
      type = lib.types.str;
      default = "${config.name}.plugin.zsh";
    };
    init = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    enable = lib.mkOption {
      default = true;
      example = false;
      description = "Enable plugin ${config.name}.";
      type = lib.types.bool;
    };
  };
})

