{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.hardware.fingerprint;
in
{
  options.premunix.hardware.fingerprint = {
    enable = lib.mkEnableOption "fingerprint support";
  };

  config = mkIf cfg.enable { services.fprintd.enable = true; };
}
