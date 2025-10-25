{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.gaming;
in
{
  options.premsnix.archetypes.gaming = {
    enable = lib.mkEnableOption "the gaming archetype";
  };

  config = mkIf cfg.enable {
    premsnix = {
      suites = {
        common = enabled;
        desktop = enabled;
        games = enabled;
      };

      services = {
        openssh = enabled;
        earlyoom = enabled;
        logrotate = enabled;
        oomd = enabled;
        printing = enabled;
        ddccontrol = enabled;
        lact = enabled;
      };
    };
  };
}
