{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premunix.services.seatd;
in
{
  options.premunix.services.seatd = {
    enable = mkEnableOption "seatd";
  };

  config = mkIf cfg.enable {
    services = {
      seatd = {
        enable = true;
        # NOTE: does it matter?
        user = config.premunix.user.name;
      };
    };
  };
}
