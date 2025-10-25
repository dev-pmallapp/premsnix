{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.business;
in
{
  options.premsnix.suites.business = {
    enable = lib.mkEnableOption "business configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "bitwarden"
        "calibre"
        "fantastical"
        "libreoffice"
        "meetingbar"
        "microsoft-teams"
        "obsidian"
      ];

      masApps = mkIf config.premsnix.tools.homebrew.masEnable {
        "Brother iPrint&Scan" = 1193539993;
        "Keynote" = 409183694;
        "Microsoft OneNote" = 784801555;
        "Notability" = 360593530;
        "Numbers" = 409203825;
        "Pages" = 409201541;
      };
    };

    premsnix = {
      programs = {
        graphical = {
          apps = {
            _1password = lib.mkDefault enabled;
          };
        };
      };
    };
  };
}
