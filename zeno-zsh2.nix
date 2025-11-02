{ wlib, lib }:
wlib.wrapModule (
  { config, wlib, ... }:
  let
    pkgs = config.pkgs;
    pluginSpecs = [
      {
        name = "fzf-tab";
        plugin = pkgs.zsh-fzf-tab;
      }
      rec {
        name = "zsh-vi-mode";
        plugin = pkgs.zsh-vi-mode;
        config = ''
          zvm_after_init_commands+=('source <(fzf --zsh)')
        '';
      }
    ];
    zshPlugins = lib.concatMapStringsSep "\n" (
      spec:
      builtins.concatStringsSep "\n" (
        [
          ''
            ##########################
            ## ${spec.name}
            ##########################
            source ${spec.plugin.src}/${spec.name}.plugin.zsh
          ''
        ]
        ++ (lib.optionals (builtins.hasAttr "config" spec) [
          "# Config"
          spec.config
        ])
      )
    ) pluginSpecs;
    zdotdir = config.pkgs.writeTextFile {
      name = "zdotdir";
      text = ''
        # Sources a file relative to the src directory
        function load {
          source ${./src}/$1
        }

        # Cleans up the environment
        function cleanup {
          unfunction load
          # unset ZDOTDIR
        }

        ${lib.optionalString config.direnv ''
          echo "Foo feature is enabled!"
        ''}

        load init.zsh

        cleanup
      '';
      destination = "/.zshrc";
    };
  in
  {
    options = {
      direnv = lib.mkEnableOption "direnv integration";
    };
    config = {
      package = config.pkgs.zsh;
      extraPackages = with pkgs; 
        [ starship ] 
        ++ lib.optional config.direnv direnv;
      env = {
        ZDOTDIR = "${zdotdir}";
      };
    };
  }
)

