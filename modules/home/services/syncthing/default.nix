{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premsnix.services.syncthing;
in
{
  options.premsnix.services.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;

      tray.enable = pkgs.stdenv.hostPlatform.isLinux;
    };
  };
}
