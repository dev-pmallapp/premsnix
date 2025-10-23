{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.business;
in
{
  options.premunix.suites.business = {
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

      masApps = mkIf config.premunix.tools.homebrew.masEnable {
        "Brother iPrint&Scan" = 1193539993;
        "Keynote" = 409183694;
        "Microsoft OneNote" = 784801555;
        "Notability" = 360593530;
        "Numbers" = 409203825;
        "Pages" = 409201541;
      };
    };

    premunix = {
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
