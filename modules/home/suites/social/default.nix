{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.social;
in
{
  options.premsnix.suites.social = {
    enable = lib.mkEnableOption "social configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        element-desktop
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        # TODO: migrate to darwin after version bump
        slack
        telegram-desktop
      ];

    premsnix = {
      programs = {
        graphical.apps = {
          caprine = lib.mkDefault enabled;
          vesktop = lib.mkDefault enabled;
        };

        terminal.social = {
          slack-term = lib.mkDefault enabled;
          twitch-tui = lib.mkDefault enabled;
        };
      };
    };
  };
}
