{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.security.keyring;
in
{
  options.premsnix.security.keyring = {
    enable = lib.mkEnableOption "gnome keyring";
  };

  config = mkIf cfg.enable {
    # NOTE: Also enables services.gnome.gcr-ssh-agent apparently
    services.gnome.gnome-keyring.enable = true;
  };
}
