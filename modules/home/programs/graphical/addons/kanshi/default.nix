{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf getExe;
  inherit (config.premunix) user;
  inherit (config.users.users.${user.name}) home;

  cfg = config.premunix.programs.graphical.addons.kanshi;
in
{
  options.premunix.programs.graphical.addons.kanshi = {
    enable = lib.mkEnableOption "Kanshi in the desktop environment";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ kanshi ];

    xdg.configFile."kanshi/config".source = ./config;

    # configuring kanshi
    systemd.user.services.kanshi = {
      description = "Kanshi output autoconfig ";
      environment = {
        XDG_CONFIG_HOME = "${home}/.config";
      };
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecCondition = # bash
          ''
            ${getExe pkgs.bash} -c '[ -n "$WAYLAND_DISPLAY" ]'
          '';

        ExecStart = # bash
          ''
            ${getExe pkgs.kanshi}
          '';

        RestartSec = 5;
        Restart = "always";
      };
    };
  };
}
