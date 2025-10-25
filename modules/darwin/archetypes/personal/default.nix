{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.personal;
in
{
  options.premsnix.archetypes.personal = {
    enable = lib.mkEnableOption "the personal archetype";
  };

  config = lib.mkIf cfg.enable {
    premsnix = {
      suites = {
        art = enabled;
        common = enabled;
        music = enabled;
        photo = enabled;
        social = enabled;
        video = enabled;
      };
    };
  };
}
