{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.display-managers.lightdm;
in
{
  options.premsnix.display-managers.lightdm = {
    enable = lib.mkEnableOption "lightdm";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager.lightdm = {
        enable = true;
        background = "${pkgs.premsnix.wallpapers}/share/wallpapers/flatppuccin_macchiato.png";

        greeters = {
          gtk = {
            enable = true;

            cursorTheme = {
              inherit (config.premsnix.desktop.addons.gtk.cursor) name;
              package = config.premsnix.desktop.addons.gtk.cursor.pkg;
            };

            iconTheme = {
              inherit (config.premsnix.desktop.addons.gtk.icon) name;
              package = config.premsnix.desktop.addons.gtk.icon.pkg;
            };

            theme = {
              name = "${config.premsnix.desktop.addons.gtk.theme.name}";
              package = config.premsnix.desktop.addons.gtk.theme.pkg;
            };
          };
        };
      };
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };
  };
}
