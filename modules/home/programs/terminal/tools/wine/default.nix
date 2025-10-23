{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.tools.wine;
in
{
  options.premunix.programs.terminal.tools.wine = {
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
