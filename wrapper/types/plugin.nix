{ lib, ... }: 
lib.types.submodule ({ config, ... }: {
  options = {
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
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
      default = if config.package != null 
      then config.package.pname
      else throw "Plugin option 'name' must be provided if 'package' is null.";
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

