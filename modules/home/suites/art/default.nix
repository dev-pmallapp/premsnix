{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.art;
in
{
  options.premsnix.suites.art = {
    enable = lib.mkEnableOption "art configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      blender
      gimp
      inkscape-with-extensions
    ];
  };
}
