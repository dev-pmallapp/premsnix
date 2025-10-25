{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premsnix.services.seatd;
in
{
  options.premsnix.services.seatd = {
    enable = mkEnableOption "seatd";
  };

  config = mkIf cfg.enable {
    services = {
      seatd = {
        enable = true;
        # NOTE: does it matter?
        user = config.premsnix.user.name;
      };
    };
  };
}
