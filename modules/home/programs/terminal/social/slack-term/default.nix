{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.social.slack-term;
in
{
  options.premsnix.programs.terminal.social.slack-term = {
    enable = lib.mkEnableOption "slack-term";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.slack-term ];

    sops.secrets = lib.mkIf (osConfig.premsnix.security.sops.enable or false) {
      slack-term = {
        sopsFile = lib.getFile "secrets/pmallapp/default.yaml";
        path = "${config.home.homeDirectory}/.config/slack-term/config";
      };
    };
  };
}
