{
  lib,
  config,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.services.power;
in
{
  options.premsnix.services.power = {
    enable = lib.mkEnableOption "power profiles";
  };

  config = mkIf cfg.enable { services.power-profiles-daemon.enable = cfg.enable; };
}
