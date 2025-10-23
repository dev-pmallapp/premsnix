{
  lib,
  pkgs,
  config,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.services.ddccontrol;
in
{
  options.premunix.services.ddccontrol = {
    enable = lib.mkEnableOption "ddccontrol";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      ddcui
      ddcutil
    ];

    services.ddccontrol = {
      enable = true;
    };
  };
}
