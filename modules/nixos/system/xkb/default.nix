{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.system.xkb;
in
{
  options.premsnix.system.xkb = {
    enable = lib.mkEnableOption "xkb";
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;

    services.xserver = {
      xkb = {
        layout = "us";
        options = "caps:escape";
      };
    };
  };
}
