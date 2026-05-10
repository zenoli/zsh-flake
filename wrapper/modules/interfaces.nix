{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  options.interfaces = {
    integratable = lib.mkOption {
      type = lib.types.deferredModule;
      readOnly = true;
      internal = true;
      default = (
        { config, name, ... }:
        {
          options = {
            enable = lib.mkEnableOption "${name} integration";
            package = lib.mkPackageOption pkgs name { };
            install = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Whether to install ${name} into $PATH.
              '';
            };
            init = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.either lib.types.str (lib.types.functionTo lib.types.str) # exe: string
              );
              description = ''
                Initialization command for ${name}.
                Can be either a string or as a function `exe -> str` where
                `exe` is the executable extracted from package.
              '';
              default = null;
            };
          };
        }
      );
    };
    sortable = lib.mkOption {
      type = lib.types.deferredModule;
      readOnly = true;
      internal = true;
      default = {
        options = {
          before = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          after = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
      };
    };
  };
}
