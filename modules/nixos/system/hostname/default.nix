{
  config,
  lib,
  hostname,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) mkBoolOpt;

  cfg = config.premsnix.system.hostname;
in
{
  options.premsnix.system.hostname = {
    enable = mkBoolOpt true "Whether to configure the system hostname.";
  };

  config = mkIf cfg.enable {
    networking.hostName = hostname;
  };
}
