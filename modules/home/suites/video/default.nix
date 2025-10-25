{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.video;
in
{
  options.premsnix.suites.video = {
    enable = lib.mkEnableOption "video configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.optionals stdenv.hostPlatform.isLinux [
        celluloid
        devede
        handbrake
        kdePackages.k3b
        mediainfo-gui
        plex-desktop
        shotcut
        vlc
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ iina ];

    premsnix = {
      programs = {
        graphical.apps = {
          obs = lib.mkDefault enabled;
          mpv = lib.mkDefault enabled;
        };
      };
    };
  };
}
