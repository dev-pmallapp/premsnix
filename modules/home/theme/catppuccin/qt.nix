{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib.premsnix) capitalize;
  cfg = config.premsnix.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    premsnix = {
      theme = {
        qt = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          theme = {
            name = "Catppuccin-Macchiato-Blue";
            package = pkgs.catppuccin-kvantum.override {
              accent = "blue";
              variant = "macchiato";
            };
          };

          settings = {
            Appearance = {
              color_scheme_path = "${pkgs.catppuccin}/qt5ct/Catppuccin-${capitalize cfg.flavor}.conf";
            };
          };
        };
      };
    };

    qt = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;

      platformTheme = {
        name = "kvantum";
      };

      style = {
        name = "kvantum";
        inherit (config.premsnix.theme.qt.theme) package;
      };
    };
  };
}
