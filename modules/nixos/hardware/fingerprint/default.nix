{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.hardware.fingerprint;
in
{
  options.premsnix.hardware.fingerprint = {
    enable = lib.mkEnableOption "fingerprint support";
  };

  config = mkIf cfg.enable { services.fprintd.enable = true; };
}
