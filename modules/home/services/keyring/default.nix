{
  config,
  lib,

  ...
}:
let

  cfg = config.premsnix.services.keyring;
in
{
  options.premsnix.services.keyring = {
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
