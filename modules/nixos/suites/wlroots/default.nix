{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.wlroots;
in
{
  options.premunix.suites.wlroots = {
    enable = lib.mkEnableOption "common wlroots configuration";
  };

  config = mkIf cfg.enable {

    premunix = {
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
