{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.graphical.file-managers.thunar;
in
{
  options.premsnix.programs.graphical.file-managers.thunar = {
    enable = lib.mkEnableOption "the xfce file manager";
  };

  config = mkIf cfg.enable {
    programs.thunar = {
      enable = true;
    };
  };
}
