{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.vm;
in
{
  options.premunix.archetypes.vm = {
    enable = lib.mkEnableOption "the vm archetype";
  };

  config = mkIf cfg.enable {
    premunix = {
      suites = {
        common = enabled;
        desktop = enabled;
        development = enabled;
        vm = enabled;
      };
    };
  };
}
