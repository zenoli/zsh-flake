{ config, wlib, lib, pkgs, ... }:
let
  zshrc = config.pkgs.writeTextFile {
    name = "zshrc";
    destination = "/.zshrc";
    text = config.zshrcContent;
  };
  zshenv = config.pkgs.writeTextFile {
    name = "zshenv";
    destination = "/.zshenv";
    text = ''
      ${
        let 
          sw = config.hmSessionVariables;
        in 
          lib.optionalString sw.enable ''
            # Home Manager session variables
            [[ -f ${sw.scriptLocation} ]] && source ${sw.scriptLocation}
          ''}
      export PATH=$PATH:${pkgs.lib.makeBinPath config.runtimePackages}
    '';
  };
  zdotdir = pkgs.symlinkJoin {
    name = "zdotdir";
    paths = [ zshrc zshenv ];
  };
  mergedSnippets = lib.concatMapStringsSep "\n\n" 
    (x: lib.trim ''
    # ${x.name}

    ${x.data}
    '') 
    (wlib.dag.sortAndUnwrap { dag = config.snippets; });
in
{
  imports = [ 
    wlib.modules.default 
    ./modules
  ];
  options = {
    zdotdir = lib.mkOption {
      type = lib.types.path;
      default = zdotdir;
      readOnly = true;
    };
    snippets = lib.mkOption {
      type = wlib.types.dagOf lib.types.str;
    };
    zshrcContent = lib.mkOption { 
      type = lib.types.str; 
      default = ''
      # Sources a file relative to the src directory
      function load {
        source "${./src}/$1"
      }

      # Cleans up the environment
      function cleanup {
        unfunction load
        # unset ZDOTDIR
      }

      ${mergedSnippets}
      '';
    };
    runtimePackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = ''
          Additional packages added to $PATH in the wrapped .zshenv.
        '';
      };
    hmSessionVariables = {
      enable = lib.mkEnableOption "home-manager sessionVariables";
      scriptLocation = lib.mkOption {
        type = lib.types.str;
        description = ''
          Absolute path of the `hm-session-vars.sh` script to be loaded.
        '';
        default = "~/.nix-profile/etc/profile.d/hm-session-vars.sh";
      };
    };
  };
  config = {
    package = pkgs.zsh;
    env = {
      ZDOTDIR = "${zdotdir}";
    };
  };
}
