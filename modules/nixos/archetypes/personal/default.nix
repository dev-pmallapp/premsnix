{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.personal;
in
{
  options.premunix.archetypes.personal = {
    enable = lib.mkEnableOption "the personal archetype";
  };

  config = mkIf cfg.enable {
    premunix = {
      services = {
        tailscale = enabled;
      };

      suites = {
        common = enabled;
      };
    };
  };
}
