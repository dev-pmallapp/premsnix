{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.games;
in
{
  options.premunix.suites.games = {
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

    premunix = {
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
