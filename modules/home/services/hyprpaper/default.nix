{
  config,
  inputs,
  lib,
  pkgs,
  system,

  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    types
    mkOption
    ;
  inherit (inputs) hypr-socket-watch;
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.services.hyprpaper;
in
{
  options.premsnix.services.hyprpaper = {
    enable = mkEnableOption "Hyprpaper";
    # enableSocketWatch = mkEnableOption "hypr-socket-watch"; # Removed: repo 404
    monitors = mkOption {
      description = "Monitors and their wallpapers";
      type =
        with types;
        listOf (submodule {
          options = {
            name = mkOption { type = str; };
            wallpaper = mkOption { type = path; };
          };
        });
    };
    wallpapers = mkOpt (types.listOf types.path) [ ] "Wallpapers to preload.";
  };

  config = mkIf cfg.enable {
    services = {
      hyprpaper = {
        enable = true;

        settings = {
          preload = cfg.wallpapers;
          wallpaper = map (monitor: "${monitor.name},${monitor.wallpaper}") cfg.monitors;
        };
      };

      # hypr-socket-watch removed (repo 404)
      # hypr-socket-watch = {
      #   enable = cfg.enableSocketWatch;
      #   package = hypr-socket-watch.packages.${system}.hypr-socket-watch;
      #   monitor = "DP-1";
      #   wallpapers = "${pkgs.premsnix.wallpapers}/share/wallpapers/";
      #   debug = false;
      # };
    };
  };
}
