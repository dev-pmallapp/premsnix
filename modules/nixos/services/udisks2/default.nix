{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) mkBoolOpt;

  cfg = config.premunix.services.udisks2;
in
{
  options.premunix.services.udisks2 = {
    enable = mkBoolOpt true "Whether or not to enable udisks2 service.";
  };

  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
    };
  };
}
