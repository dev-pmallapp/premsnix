{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.hardware.fans;
in
{
  options.premsnix.hardware.fans = {
    enable = lib.mkEnableOption "support for fan control";
  };

  config = mkIf cfg.enable {
    programs.coolercontrol.enable = true;
  };
}
