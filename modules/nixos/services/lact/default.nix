{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.services.lact;
in
{
  options.premsnix.services.lact = {
    enable = lib.mkEnableOption "lact";
  };

  config = mkIf cfg.enable {
    services.lact.enable = true;
  };
}
