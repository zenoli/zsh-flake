{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  zshrc = config.pkgs.writeTextFile {
    name = "zshrc";
    destination = "/.zshrc";
    text = config.zshrcContent;
  };
  mergedSnippets = lib.concatMapStringsSep "\n\n" (
    x:
    # lib.trim drops the string context, which would stop nix from building
    # (and keeping at runtime) the store paths referenced in the snippets.
    lib.addContextFrom x.data (
      lib.trim ''
        # ${x.name}

        ${x.data}
      ''
    )
  ) (wlib.dag.sortAndUnwrap { dag = config.snippets; });
  types = (import ./types) { inherit pkgs lib; };
  after = name: {
    after = [ name ];
    data = wlib.ignoreSpecField;
  };
  before = name: {
    before = [ name ];
    data = wlib.ignoreSpecField;
  };
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
    # The NixOS /etc/zshrc runs its own (uncached, since ZDOTDIR is read-only)
    # compinit, promptinit, etc. which roughly doubles the startup time.
    # Everything we need from it is re-done below or in our own snippets.
    skipGlobalRC = lib.mkDefault true;
    zshAliases = {
      p = "echo $PATH | tr ':' '\n'";
      ls = "ls --color=tty";
      l = "ls -alh";
      ll = "ls -l";
    };
    snippets = {
      lsColors = lib.mkIf config.skipGlobalRC (
        lib.mkDefault "source ${config.utils.initScript "${pkgs.coreutils}/bin/dircolors" "-b"}"
      );
      completion = after "p10kInstantPrompt";
      plugins = after "completion";
      integrations = after "plugins";
    };
    zshrc.content =
      mergedSnippets
      + "\n\n"
      + (lib.optionalString (config.zshSrc.directory != null) ''
        # Sources a file relative to the src directory
        function load {
          source "${config.zshSrc.directory}/$1"
        }

        # Cleans up the environment
        function cleanup {
          unfunction load
          # unset ZDOTDIR
        }
        function init {
          load ${config.zshSrc.initFile}
        }

        init

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
  };
}
