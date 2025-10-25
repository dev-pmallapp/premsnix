{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.photo;
in
{
  options.premsnix.suites.photo = {
    enable = lib.mkEnableOption "photo configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [ ];
    };
  };
}
