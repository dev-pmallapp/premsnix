{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.games;
in
{
  options.premsnix.suites.games = {
    enable = lib.mkEnableOption "common games configuration";
  };

  config = mkIf cfg.enable {
    # TODO: sober/roblox?
    home.packages = with pkgs; [
      bottles
      heroic
      lutris
      prismlauncher
      protontricks
      protonup-ng
      protonup-qt
      umu-launcher
      wowup-cf
    ];

    premsnix = {
      programs = {
        terminal = {
          tools = {
            wine = lib.mkDefault enabled;
          };
        };
      };
    };
  };
}
