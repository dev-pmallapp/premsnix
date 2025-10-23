{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.graphical.apps.gnome-disks;
in
{
  options.premunix.programs.graphical.apps.gnome-disks = {
    enable = lib.mkEnableOption "gnome-disks";
  };

  config = mkIf cfg.enable {
    programs.gnome-disks = {
      enable = true;
    };
  };
}
