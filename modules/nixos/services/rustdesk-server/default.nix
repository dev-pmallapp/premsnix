{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.services.rustdesk-server;
in
{
  options.premsnix.services.rustdesk-server = {
    enable = mkEnableOption "rustdesk-server";
    relayHosts = mkOpt (lib.types.listOf lib.types.str) [ ] "Groups for the user to be assigned.";
  };

  config = mkIf cfg.enable {
    services = {
      rustdesk-server = {
        enable = true;
        # Default
        # relay.enable = true;
        signal = {
          # Default
          # enable = true;
          inherit (cfg) relayHosts;
        };
      };
    };
  };
}
