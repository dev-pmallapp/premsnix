{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.video;
in
{
  options.premunix.suites.video = {
    enable = lib.mkEnableOption "video configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ffmpeg ];

    homebrew = {
      casks = [
        "plex"
      ];

      masApps = mkIf config.premunix.tools.homebrew.masEnable {
        "Infuse" = 1136220934;
        "iMovie" = 408981434;
      };
    };
  };
}
