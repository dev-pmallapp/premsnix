{
  config,
  lib,

  ...
}:
let
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.desktop;
in
{
  options.premunix.suites.desktop = {
    enable = lib.mkEnableOption "common desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    premunix = {
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
