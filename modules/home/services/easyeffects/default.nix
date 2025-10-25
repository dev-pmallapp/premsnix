{
  config,
  lib,

  ...
}:
let
  cfg = config.premsnix.services.easyeffects;
in
{
  options.premsnix.services.easyeffects = {
    enable = lib.mkEnableOption "easyeffects";
  };

  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;

      preset = "quiet";
    };

    xdg.configFile."easyeffects/output/quiet.json".source = ./quiet.json;
  };
}
