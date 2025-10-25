{
  lib,
  pkgs,
  config,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.services.cloudflared;
in
{
  options.premsnix.services.cloudflared = {
    enable = lib.mkEnableOption "cloudflared";
  };

  config = mkIf cfg.enable {
    # NOTE: future reference for adding assertions
    # assertions = [
    #   {
    #     assertion = cfg.autoconnect.enable -> cfg.autoconnect.key != "";
    #     message = "premsnix.services.cloudflared.autoconnect.key must be set";
    #   }
    # ];

    services.cloudflared = {
      enable = true;
      package = pkgs.cloudflared;

      tunnels = {
        "KHANELIMANCOM" = {
          # TODO: replace with sops secret
          credentialsFile = "REPLACEME";
          default = "http_status:404";
          ingress = {
            "pmallapp.com" = {
              # TODO: replace with sops secret
              service = "https://ip:port";
              originRequest = {
                noTLSVerify = true;
                originServerName = "pmallapp.com";
              };
            };
          };
        };
      };
    };
  };
}
