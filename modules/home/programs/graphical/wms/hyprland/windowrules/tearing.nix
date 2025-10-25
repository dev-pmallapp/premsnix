{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.premsnix.programs.graphical.wms.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        windowrule = [
          "immediate, class:^(gamescope|steam_app).*"
        ];
      };
    };
  };
}
