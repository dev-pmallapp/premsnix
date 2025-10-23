{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.system.xkb;
in
{
  options.premunix.system.xkb = {
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
