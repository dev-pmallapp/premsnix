{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let

  cfg = config.premsnix.programs.terminal.social.twitch-tui;
in
{
  options.premsnix.programs.terminal.social.twitch-tui = {
    enable = lib.mkEnableOption "twitch-tui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.twitch-tui ];

    sops.secrets = lib.mkIf (osConfig.premsnix.security.sops.enable or false) {
      twitch-tui = {
        sopsFile = lib.getFile "secrets/pmallapp/default.yaml";
        path = "${config.home.homeDirectory}/.config/twt/config.toml";
      };
    };
  };
}
