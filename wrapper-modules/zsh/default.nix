{ config, wlib, lib, pkgs, ... }:
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
  };
  config = {
    zshrc.content = ''
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
}
