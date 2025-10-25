{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.desktop;
in
{
  options.premsnix.suites.desktop = {
    enable = lib.mkEnableOption "common desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    premsnix = {
      programs = {
        graphical = {
          addons = {
            keyring = lib.mkDefault enabled;
          };

          apps = {
            _1password = lib.mkDefault enabled;
          };
        };
      };

      services = {
        flatpak = lib.mkDefault enabled;
      };
    };
  };
}
