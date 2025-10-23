{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premunix.services.tailscale;
in
{
  options.premunix.services.tailscale = {
    enable = mkEnableOption "tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale-systray.enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}
