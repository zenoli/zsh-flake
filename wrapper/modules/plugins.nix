{ config, wlib, lib, pkgs, ... }:
let
  types = (import ../types) { inherit pkgs lib; };
  enabledPlugins = lib.filter (p: p.enable) config.plugins;
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
  # This somehow causes the plugin sources (pluginPackage.src) to be fetched.
  # Without it the sources are not downloaded to the nix store and the plugins 
  # cannot be sourced.
  # This hack somehow tells nix that these packages are needed during runtime
  # but I have no idea why...
  config.drv.preBuild = "echo '${pluginConfig}'";
}
