{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.networking;
in
{
  options.premunix.suites.networking = {
    enable = lib.mkEnableOption "networking configuration";
  };

  config = mkIf cfg.enable {
    premunix = {
      services = {
        tailscale = lib.mkDefault enabled;
      };

      system = {
        networking = lib.mkDefault enabled;
      };
    };
  };
}
