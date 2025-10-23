{
  config,
  lib,

  ...
}:
let
  cfg = config.premunix.services.easyeffects;
in
{
  options.premunix.services.easyeffects = {
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
