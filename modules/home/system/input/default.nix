{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premsnix.system.input;
in
{
  options.premsnix.system.input = {
    enable = mkEnableOption "macOS input";
  };

  config = mkIf cfg.enable {
    services.macos-remap-keys = {
      enable = true;
      keyboard = {
        Capslock = "Escape";
      };
    };
  };
}
