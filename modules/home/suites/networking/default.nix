{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.networking;
in
{
  options.premunix.suites.networking = {
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

    premunix.services.tailscale.enable = osConfig.services.tailscale.enable or false;
  };
}
