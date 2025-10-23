{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let

  cfg = config.premunix.programs.terminal.social.twitch-tui;
in
{
  options.premunix.programs.terminal.social.twitch-tui = {
    enable = lib.mkEnableOption "twitch-tui";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.twitch-tui ];

    sops.secrets = lib.mkIf (osConfig.premunix.security.sops.enable or false) {
      twitch-tui = {
        sopsFile = lib.getFile "secrets/pmallapp/default.yaml";
        path = "${config.home.homeDirectory}/.config/twt/config.toml";
      };
    };
  };
}
