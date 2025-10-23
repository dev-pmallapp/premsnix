{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.music;
in
{
  options.premunix.suites.music = {
    enable = lib.mkEnableOption "music configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      masApps = mkIf config.premunix.tools.homebrew.masEnable { "GarageBand" = 682658836; };
    };
  };
}
