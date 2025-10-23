{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.server;
in
{
  options.premunix.archetypes.server = {
    enable = lib.mkEnableOption "the server archetype";
  };

  config = mkIf cfg.enable {
    premunix = {
      suites = {
        common = enabled;
      };
    };
  };
}
