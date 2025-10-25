{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.wlroots;
in
{
  options.premsnix.suites.wlroots = {
    enable = lib.mkEnableOption "common wlroots configuration";
  };

  config = mkIf cfg.enable {

    premsnix = {
      services = {
        seatd = mkDefault enabled;
      };
    };
    programs = {
      xwayland.enable = mkDefault true;

      wshowkeys = {
        enable = mkDefault true;
        package = pkgs.wshowkeys;
      };
    };
  };
}
