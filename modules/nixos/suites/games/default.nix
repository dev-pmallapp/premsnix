{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkDefault;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.games;
in
{
  options.premunix.suites.games = {
    enable = lib.mkEnableOption "common games configuration";
  };

  config = lib.mkIf cfg.enable {
    premunix = {
      programs = {
        graphical = {
          addons = {
            gamemode = mkDefault enabled;
            gamescope = mkDefault enabled;
            # mangohud = mkDefault enabled;
          };

          apps = {
            steam = mkDefault enabled;
          };
        };
      };

      services.flatpak.extraPackages = [
        # Sober for Roblox
        {
          appId = "org.vinegarhq.Sober";
          origin = "flathub";
        }
      ];
    };
  };
}
