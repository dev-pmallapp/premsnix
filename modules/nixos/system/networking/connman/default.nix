{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.system.networking;
in
{
  config = mkIf (cfg.enable && cfg.manager == "connman") {
    services.connman = {
      enable = true;

      networkInterfaceBlacklist = [
        "vmnet"
        "vboxnet"
        "virbr"
        "ifb"
        "ve"
      ]
      ++ lib.optionals config.premsnix.services.tailscale.enable [ "tailscale*" ]
      ++ lib.optionals config.premsnix.virtualisation.podman.enable [ "docker*" ];
    };
  };
}
