{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    types
    ;

  # Use direct mkOpt implementation to avoid circular dependency
  mkOpt =
    type: default: description:
    lib.mkOption { inherit type default description; };

  cfg = config.premunix.theme.stylix;
in
{
  options.premunix.theme.stylix = {
    enable = mkEnableOption "stylix theme for applications";
    theme = mkOpt types.str "catppuccin-macchiato" "base16 theme file name";

    cursor = {
      name = mkOpt types.str "catppuccin-macchiato-blue-cursors" "The name of the cursor theme to apply.";
      package = mkOpt types.package (
        if pkgs.stdenv.hostPlatform.isLinux then
          pkgs.catppuccin-cursors.macchiatoBlue
        else
          pkgs.emptyDirectory
      ) "The package to use for the cursor theme.";
      size = mkOpt types.int 32 "The size of the cursor.";
    };

    icon = {
      name = mkOpt types.str "Papirus-Dark" "The name of the icon theme to apply.";
      package = mkOpt types.package (pkgs.catppuccin-papirus-folders.override {
        accent = "blue";
        flavor = "macchiato";
      }) "The package to use for the icon theme.";
    };
  };

  config = mkIf cfg.enable (
    lib.optionalAttrs (options ? stylix) {
      home = mkIf (pkgs.stdenv.hostPlatform.isLinux && !config.premunix.theme.catppuccin.enable) {
        pointerCursor = {
          inherit (cfg.cursor) name package size;
        };
      };

      gtk.gtk3 = mkIf (pkgs.stdenv.hostPlatform.isLinux && !config.premunix.theme.catppuccin.enable) {
        font = null;
      };

      stylix = {
        enable = true;
        # autoEnable = false;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

        cursor = lib.mkOptionDefault cfg.cursor;

        fonts = {
          sizes = {
            desktop = 11;
            applications = 12;
            terminal = 13;
            popups = 12;
          };

          serif = {
            package = pkgs.monaspace;
            name = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Neon" else "MonaspaceNeon";
          };
          sansSerif = {
            package = pkgs.monaspace;
            name = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Neon" else "MonaspaceNeon";
          };
          monospace = {
            package = pkgs.monaspace;
            name = if pkgs.stdenv.hostPlatform.isDarwin then "Monaspace Krypton" else "MonaspaceKrypton";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };

        icons = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          enable = lib.mkDefault true;
          inherit (cfg.icon) package;
          dark = cfg.icon.name;
          # TODO: support custom light
          light = cfg.icon.name;
        };

        polarity = "dark";

        opacity = {
          desktop = 1.0;
          applications = 0.90;
          terminal = 0.90;
          popups = 1.0;
        };

        targets = {
          # Set profile names for firefox
          firefox.profileNames = [ config.premunix.user.name ];

          # TODO: Very custom styling, integrate with their variables
          # Currently setup only for catppuccin/nix
          vscode.enable = false;

          # Disable targets when catppuccin is enabled
          alacritty.enable = !config.premunix.theme.catppuccin.enable;
          bat.enable = !config.premunix.theme.catppuccin.enable;
          btop.enable = !config.premunix.theme.catppuccin.enable;
          cava.enable = !config.premunix.theme.catppuccin.enable;
          fish.enable = !config.premunix.theme.catppuccin.enable;
          foot.enable = !config.premunix.theme.catppuccin.enable;
          fzf.enable = !config.premunix.theme.catppuccin.enable;
          ghostty.enable = !config.premunix.theme.catppuccin.enable;
          gitui.enable = !config.premunix.theme.catppuccin.enable;
          helix.enable = !config.premunix.theme.catppuccin.enable;
          k9s.enable = !config.premunix.theme.catppuccin.enable;
          kitty = {
            enable = !config.premunix.theme.catppuccin.enable;
          };
          lazygit.enable = !config.premunix.theme.catppuccin.enable;
          ncspot.enable = !config.premunix.theme.catppuccin.enable;
          neovim.enable = !config.premunix.theme.catppuccin.enable;
          tmux.enable = !config.premunix.theme.catppuccin.enable;
          vesktop.enable = !config.premunix.theme.catppuccin.enable;
          yazi.enable = !config.premunix.theme.catppuccin.enable;
          zathura.enable = !config.premunix.theme.catppuccin.enable;
          zellij.enable = !config.premunix.theme.catppuccin.enable;
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          gnome.enable = !config.premunix.theme.catppuccin.enable;
          # FIXME: not working
          gtk.enable = false;
          hyprland.enable = !config.premunix.theme.catppuccin.enable;
          # FIXME:: upstream needs module fix
          hyprlock.useWallpaper = false;
          hyprlock.enable = false;
          qt.enable = !config.premunix.theme.catppuccin.enable;
          sway.enable = !config.premunix.theme.catppuccin.enable;
          # TODO: Very custom styling, integrate with their variables
          # Currently setup only for catppuccin/nix
          swaync.enable = false;
          waybar.enable = !config.premunix.theme.catppuccin.enable;
        };
      };
    }
  );
}
