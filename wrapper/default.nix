{ config, wlib, lib, pkgs, ... }@top :
let
  zshrc = config.pkgs.writeTextFile {
    name = "zshrc";
    destination = "/.zshrc";
    text = config.zshrcContent;
  };
  mergedSnippets = lib.concatMapStringsSep "\n\n" 
    (x: lib.trim ''
    # ${x.name}

    ${x.data}
    '') 
    (wlib.dag.sortAndUnwrap { dag = config.snippets; });
  types = (import ./types) { inherit pkgs lib; };
in
{
  imports = [ 
    wlib.wrapperModules.zsh 
    ./modules
  ];
  options = {
    snippets = lib.mkOption {
      type = wlib.types.dagOf lib.types.str;
    };
    zshSrc = {
      directory = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
      };
      initFile = lib.mkOption {
        type = lib.types.str;
        default = "init.zsh";
      };
    };

    extraPackages' = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Like extraPackages but packages are prefixed instead of suffixed.

        Additional packages to add to the wrapper's runtime PATH.
        This is useful if the wrapped program needs additional libraries or tools to function correctly.

        Adds all its entries to the DAG under the name `NIX_PATH_ADDITIONS`
      '';
    };
  };
  config = {
    zshAliases = {
      p = "echo $PATH | tr ':' '\n'";
      nhs = "home-manager switch --flake \$NIXOS_CONFIG";
      nos = "sudo nixos-rebuild switch --flake \$NIXOS_CONFIG";

    };
    zshrc.content = mergedSnippets + "\n\n" +  (lib.optionalString (config.zshSrc.directory != null) ''
      # Sources a file relative to the src directory
      function load {
        source "${config.zshSrc.directory}/$1"
      }

      # Cleans up the environment
      function cleanup {
        unfunction load
        # unset ZDOTDIR
      }
      load ${config.zshSrc.initFile}

      cleanup
    '');
    prefixVar = lib.toList {
      name = "NIX_PATH_ADDITIONS";
      data = [
        "PATH"
          ":"
          "${lib.makeBinPath config.extraPackages'}"
      ];
    };
    install.modules = 
    let
      cfg = top.config.install.getWrapperConfig config;
    in
    {
      homeManager = { config, lib, ... }: {
        config = lib.mkMerge [
          (top.config.install.addWrapperModule "${./default.nix} zsh kittyIntegration" {
            _file = ./module.nix;
            options.kittyIntegration = lib.mkEnableOption "kitty integration";
          })
          (lib.mkIf cfg.enable {
            # programs.kitty.settings.shell = lib.mkIf cfg.kittyIntegration (lib.getExe cfg.wrapper);
            programs.kitty.settings.shell = lib.getExe cfg.wrapper;
          })
        ];
      };

      nixos = { config, lib, ... }: {
        config = lib.mkMerge [
          (top.config.install.addWrapperModule "${./default.nix} zsh as userShell" {
            _file = ./module.nix;
            options.userShell = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "zsh as userShell";
              default = null;
            };
          })
          (lib.mkIf cfg.enable {
            users.users = lib.mkIf (cfg.userShell != null) {
              "${cfg.userShell}".shell = lib.getExe cfg.wrapper;
            };
            programs.zsh.enable = lib.mkIf (cfg.asSystemDefault || cfg.userShell != null) true;
          })
        ];
      };
    };
  };
}
