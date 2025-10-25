{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) mkBoolOpt;

  cfg = config.premsnix.services.udisks2;
in
{
  options.premsnix.services.udisks2 = {
    enable = mkBoolOpt true "Whether or not to enable udisks2 service.";
  };

  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
    };
  };
}
