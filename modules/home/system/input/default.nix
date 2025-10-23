{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premunix.system.input;
in
{
  options.premunix.system.input = {
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
