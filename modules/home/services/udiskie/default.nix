{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premsnix.services.udiskie;
in
{
  options.premsnix.services.udiskie = {
    enable = mkEnableOption "udiskie";
  };

  config = mkIf cfg.enable {
    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };
  };
}
