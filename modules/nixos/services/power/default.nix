{
  lib,
  config,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.services.power;
in
{
  options.premunix.services.power = {
    enable = lib.mkEnableOption "power profiles";
  };

  config = mkIf cfg.enable { services.power-profiles-daemon.enable = cfg.enable; };
}
