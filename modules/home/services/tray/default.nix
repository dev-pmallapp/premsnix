{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premsnix.services.tray;
in
{
  options.premsnix.services.tray = {
    enable = mkEnableOption "tray";
  };

  config = mkIf cfg.enable {
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };
}
