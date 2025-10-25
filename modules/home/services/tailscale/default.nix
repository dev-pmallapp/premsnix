{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premsnix.services.tailscale;
in
{
  options.premsnix.services.tailscale = {
    enable = mkEnableOption "tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale-systray.enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}
