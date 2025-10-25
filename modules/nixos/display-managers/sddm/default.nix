{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf getExe' stringAfter;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.display-managers.sddm;

  userName = config.premsnix.user.name;
in
{
  options.premsnix.display-managers.sddm = {
    enable = lib.mkEnableOption "sddm";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      catppuccin-sddm-corners
    ];

    premsnix.home.configFile =
      let
        icon = lib.attrByPath [ "home-manager" "users" userName "premsnix" "user" "icon" ] null config;
      in
      lib.mkIf (icon != null) {
        "sddm/faces/.${userName}".source = icon;
      };

    services = {
      displayManager = {
        sddm = {
          inherit (cfg) enable;
          # package = pkgs.libsForQt5.sddm;
          # TODO: update theme support
          package = pkgs.kdePackages.sddm;
          theme = "catppuccin-sddm-corners";
          wayland = enabled;
        };
      };
    };

    system.activationScripts.postInstallSddm =
      stringAfter [ "users" ] # Bash
        ''
          echo "Setting sddm permissions for user icon"
          ${getExe' pkgs.acl "setfacl"} -m u:sddm:x /home/${userName}
          ${getExe' pkgs.acl "setfacl"} -m u:sddm:r /home/${userName}/.face.icon || true
        '';
  };
}
