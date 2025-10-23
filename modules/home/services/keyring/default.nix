{
  config,
  lib,

  ...
}:
let

  cfg = config.premunix.services.keyring;
in
{
  options.premunix.services.keyring = {
    enable = lib.mkEnableOption "gnome keyring";
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;

      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };
  };
}
