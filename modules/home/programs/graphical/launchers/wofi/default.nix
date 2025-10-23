{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.graphical.addons.wofi;
in
{
  options.premunix.programs.graphical.addons.wofi = {
    enable = lib.mkEnableOption "the Wofi in the desktop environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wofi
      wofi-emoji
    ];

    xdg.configFile = {
      "wofi/config".source = ./config;
      "wofi/style.css".source = ./style.css;
    };
  };
}
