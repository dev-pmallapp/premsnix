{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.graphical.apps.gnome-disks;
in
{
  options.premsnix.programs.graphical.apps.gnome-disks = {
    enable = lib.mkEnableOption "gnome-disks";
  };

  config = mkIf cfg.enable {
    programs.gnome-disks = {
      enable = true;
    };
  };
}
