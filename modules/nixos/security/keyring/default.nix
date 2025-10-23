{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.security.keyring;
in
{
  options.premunix.security.keyring = {
    enable = lib.mkEnableOption "gnome keyring";
  };

  config = mkIf cfg.enable {
    # NOTE: Also enables services.gnome.gcr-ssh-agent apparently
    services.gnome.gnome-keyring.enable = true;
  };
}
