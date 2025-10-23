{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.tools.qmk;
in
{
  options.premunix.tools.qmk = {
    enable = lib.mkEnableOption "QMK";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ qmk ];

    services.udev.packages = with pkgs; [ qmk-udev-rules ];
  };
}
