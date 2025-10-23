{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.services.lact;
in
{
  options.premunix.services.lact = {
    enable = lib.mkEnableOption "lact";
  };

  config = mkIf cfg.enable {
    services.lact.enable = true;
  };
}
