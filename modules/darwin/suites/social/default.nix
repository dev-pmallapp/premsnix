{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.social;
in
{
  options.premunix.suites.social = {
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
