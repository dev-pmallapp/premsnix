{
  config,
  lib,

  ...
}:
let
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.personal;
in
{
  options.premunix.archetypes.personal = {
    enable = lib.mkEnableOption "the personal archetype";
  };

  config = lib.mkIf cfg.enable {
    premunix = {
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
