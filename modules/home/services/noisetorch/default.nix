{
  osConfig ? { },
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) getExe mkIf mkEnableOption;

  cfg = config.premsnix.services.noisetorch;
  osCfg = osConfig.premsnix.programs.graphical.addons.noisetorch or { };
in
{
  options = {
    premsnix.services.noisetorch = {
      enable = mkEnableOption "noisetorch service";
    };
  };

  config = mkIf (cfg.enable && (osCfg.enable or false)) {
    systemd.user.services.noisetorch = {
      Install = {
        WantedBy = [ "default.target" ];
      };

      Unit = {
        Description = "Noisetorch Noise Cancelling";
        Requires = [ "${osCfg.deviceUnit or ""}" ];
        After = [ "${osCfg.deviceUnit or ""}" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${getExe (osCfg.package or pkgs.noisetorch)} -i -s ${osCfg.device or ""} -t ${
          builtins.toString (osCfg.threshold or 95)
        }";
        ExecStop = "${getExe (osCfg.package or pkgs.noisetorch)} -u";
        Restart = "always";
        RestartSec = 3;
        Nice = -10;
      };
    };
  };
}
