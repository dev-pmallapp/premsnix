{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.gaming;
in
{
  options.premunix.archetypes.gaming = {
    enable = lib.mkEnableOption "the gaming archetype";
  };

  config = mkIf cfg.enable {
    premunix.suites = {
      common = enabled;
      desktop = enabled;
      games = enabled;
    };
  };
}
