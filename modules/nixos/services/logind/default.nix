{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premsnix.services.logind;
in
{
  options.premsnix.services.logind = {
    enable = mkEnableOption "logind";
  };

  config = mkIf cfg.enable {
    services = {
      logind.settings.Login = {
        KillUserProcesses = true;
      };
    };
  };
}
