{
  config,
  lib,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premsnix.services.cliphist;
in
{
  options.premsnix.services.cliphist = {
    enable = mkEnableOption "cliphist";

    systemdTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Systemd targets for cliphist
      '';
    };
  };

  config = mkIf cfg.enable {
    services = {
      cliphist = {
        enable = true;
        allowImages = true;
        systemdTargets =
          cfg.systemdTargets
          ++ lib.optionals (
            (config.wayland.windowManager.hyprland.enable && (osConfig.programs.hyprland.withUWSM or false))
            || (config.wayland.windowManager.sway.enable && (osConfig.programs.uwsm.enable or false))
          ) [ "graphical-session.target" ]
          ++
            lib.optionals
              (config.wayland.windowManager.hyprland.enable && !(osConfig.programs.hyprland.withUWSM or false))
              [
                "hyprland-session.target"
              ]
          ++ lib.optionals (
            config.wayland.windowManager.sway.enable && !(osConfig.programs.uwsm.enable or false)
          ) [ "sway-session.target" ];

      };
    };
  };
}
