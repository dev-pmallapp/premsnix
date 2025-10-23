{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.display-managers.lightdm;
in
{
  options.premunix.display-managers.lightdm = {
    enable = lib.mkEnableOption "lightdm";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager.lightdm = {
        enable = true;
        background = "${pkgs.premunix.wallpapers}/share/wallpapers/flatppuccin_macchiato.png";

        greeters = {
          gtk = {
            enable = true;

            cursorTheme = {
              inherit (config.premunix.desktop.addons.gtk.cursor) name;
              package = config.premunix.desktop.addons.gtk.cursor.pkg;
            };

            iconTheme = {
              inherit (config.premunix.desktop.addons.gtk.icon) name;
              package = config.premunix.desktop.addons.gtk.icon.pkg;
            };

            theme = {
              name = "${config.premunix.desktop.addons.gtk.theme.name}";
              package = config.premunix.desktop.addons.gtk.theme.pkg;
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
