{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.tools.wine;
in
{
  options.premsnix.programs.terminal.tools.wine = {
    enable = lib.mkEnableOption "Wine";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      winetricks
      # wineWowPackages.stable
      wineWowPackages.waylandFull
    ];
  };
}
