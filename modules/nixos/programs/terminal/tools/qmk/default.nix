{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.tools.qmk;
in
{
  options.premsnix.tools.qmk = {
    enable = lib.mkEnableOption "QMK";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ qmk ];

    services.udev.packages = with pkgs; [ qmk-udev-rules ];
  };
}
