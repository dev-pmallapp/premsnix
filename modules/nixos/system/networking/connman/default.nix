{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.system.networking;
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
      ++ lib.optionals config.premunix.services.tailscale.enable [ "tailscale*" ]
      ++ lib.optionals config.premunix.virtualisation.podman.enable [ "docker*" ];
    };
  };
}
