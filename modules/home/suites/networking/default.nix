{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.networking;
in
{
  options.premsnix.suites.networking = {
    enable = lib.mkEnableOption "networking configuration";
  };

  config = mkIf cfg.enable {

    home.packages =
      with pkgs;
      [
        nmap
        openssh
        speedtest-cli
        ssh-copy-id
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ iproute2 ];

    premsnix.services.tailscale.enable = osConfig.services.tailscale.enable or false;
  };
}
