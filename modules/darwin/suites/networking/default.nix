{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.networking;
in
{
  options.premsnix.suites.networking = {
    enable = lib.mkEnableOption "networking configuration";
  };

  config = mkIf cfg.enable {
    premsnix = {
      services = {
        tailscale = lib.mkDefault enabled;
      };

      system = {
        networking = lib.mkDefault enabled;
      };
    };
  };
}
