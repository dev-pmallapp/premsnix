{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) mkBoolOpt;

  cfg = config.premsnix.services.dbus;
in
{
  options.premsnix.services.dbus = {
    enable = mkBoolOpt true "Whether or not to enable dbus service.";
  };

  config = mkIf cfg.enable {
    services.dbus = {
      enable = true;

      implementation = "broker";
    };
  };
}
