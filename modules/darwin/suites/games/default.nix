{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.games;
in
{
  options.premsnix.suites.games = {
    enable = lib.mkEnableOption "games configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "moonlight"
        "steam"
      ];
    };
  };
}
