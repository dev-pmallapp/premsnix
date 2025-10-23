{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) mkBoolOpt;

  cfg = config.premunix.services.dbus;
in
{
  options.premunix.services.dbus = {
    enable = mkBoolOpt true "Whether or not to enable dbus service.";
  };

  config = mkIf cfg.enable {
    services.dbus = {
      enable = true;

      implementation = "broker";
    };
  };
}
