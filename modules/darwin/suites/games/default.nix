{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.games;
in
{
  options.premunix.suites.games = {
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
