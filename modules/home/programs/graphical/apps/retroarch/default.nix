{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.graphical.apps.retroarch;
in
{
  options.premsnix.programs.graphical.apps.retroarch = {
    enable = lib.mkEnableOption "retroarch";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.retroarch.withCores (
        cores: with cores; [
          beetle-psx-hw
          bsnes
          # FIXME: broken nixpkgs
          # citra
          # dolphin
          dosbox
          genesis-plus-gx
          mame
          mgba
          nestopia
          pcsx2
          snes9x
        ]
      ))
    ];
  };
}
