{ config, wlib, lib, pkgs, ... }:
let
  types = (import ../types) { inherit pkgs lib; };
  enabledPlugins = lib.filter (p: !p.disable) config.plugins;
  pluginConfig = lib.concatMapStringsSep "\n" (
    plugin:
    builtins.concatStringsSep "\n" (
      [
        ''
          ## ${plugin.name}
          source "${plugin.src}/${plugin.file}"
        ''
      ]
      ++ (lib.optional (plugin.init != null) plugin.init
      )
    )
  ) enabledPlugins;
in
{
  options = {
    plugins = lib.mkOption {
      default = [ ];
      type = lib.types.listOf types.plugin;
      description = "List of zsh plugins.";
    };
  };
  config.snippets.plugins = wlib.dag.entryAfter [ "completion" ] pluginConfig;
}
