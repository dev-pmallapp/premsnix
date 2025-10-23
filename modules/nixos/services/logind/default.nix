{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premunix.services.logind;
in
{
  options.premunix.services.logind = {
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
