{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.music;
in
{
  options.premsnix.suites.music = {
    enable = lib.mkEnableOption "music configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      masApps = mkIf config.premsnix.tools.homebrew.masEnable { "GarageBand" = 682658836; };
    };
  };
}
