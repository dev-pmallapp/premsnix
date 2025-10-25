{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.server;
in
{
  options.premsnix.archetypes.server = {
    enable = lib.mkEnableOption "the server archetype";
  };

  config = mkIf cfg.enable {
    premsnix = {
      suites = {
        common = enabled;
      };

      services = {
        openssh = enabled;
        earlyoom = enabled;
        logrotate = enabled;
        oomd = enabled;
        # hardware specific (lact, ddccontrol) intentionally omitted for server
        # Do not force printing here; leave to workstation/gaming archetypes or explicit host configs
      };
    };

    # Hardware / admin tools moved from common suite
    environment.systemPackages = with pkgs; [
      lshw
      pciutils
      rsync
    ];
  };
}
