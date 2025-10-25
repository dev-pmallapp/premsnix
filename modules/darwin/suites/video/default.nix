{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.video;
in
{
  options.premsnix.suites.video = {
    enable = lib.mkEnableOption "video configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ffmpeg ];

    homebrew = {
      casks = [
        "plex"
      ];

      masApps = mkIf config.premsnix.tools.homebrew.masEnable {
        "Infuse" = 1136220934;
        "iMovie" = 408981434;
      };
    };
  };
}
