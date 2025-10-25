{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.workstation;
in
{
  options.premsnix.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      deskflow
      lshw
      pciutils
      rsync
    ];

    premsnix = {
      suites = {
        common = enabled;
        desktop = enabled;
        development = enabled;
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
