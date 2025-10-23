{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premunix.services.syncthing;
in
{
  options.premunix.services.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;

      tray.enable = pkgs.stdenv.hostPlatform.isLinux;
    };
  };
}
