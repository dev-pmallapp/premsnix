{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.vm;
in
{
  options.premsnix.archetypes.vm = {
    enable = lib.mkEnableOption "the vm archetype";
  };

  config = lib.mkIf cfg.enable {
    premsnix = {
      suites = {
        common = enabled;
        desktop = enabled;
        development = enabled;
        vm = enabled;
      };
    };
  };
}
