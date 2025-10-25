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
    environment.systemPackages = with pkgs; [
      imagemagick
      pngcheck
    ];

    homebrew = {
      casks = [
        "blender"
        "gimp"
        "inkscape"
        "mediainfo"
      ];

      masApps = mkIf config.premsnix.tools.homebrew.masEnable { "Pixelmator" = 407963104; };
    };
  };
}
