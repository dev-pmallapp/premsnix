{
  config,
  lib,
  hostname,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) mkBoolOpt;

  cfg = config.premunix.system.hostname;
in
{
  options.premunix.system.hostname = {
    enable = mkBoolOpt true "Whether to configure the system hostname.";
  };

  config = mkIf cfg.enable {
    networking.hostName = hostname;
  };
}
