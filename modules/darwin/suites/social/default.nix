{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.social;
in
{
  options.premsnix.suites.social = {
    enable = lib.mkEnableOption "social configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "slack@beta"
      ];
    };
  };
}
