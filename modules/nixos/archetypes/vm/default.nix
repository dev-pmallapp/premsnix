{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.vm;
in
{
  options.premsnix.archetypes.vm = {
    enable = lib.mkEnableOption "the vm archetype";
  };

  config = mkIf cfg.enable {
    premsnix = {
      suites = {
        common = enabled;
        desktop = enabled;
        development = enabled;
        vm = enabled;
      };

      services = {
        openssh = enabled;
        earlyoom = enabled;
        logrotate = enabled;
        # Keep oomd optional for VMs; still enable for parity with previous common
        oomd = enabled;
        printing = enabled; # retain unless explicitly disabled elsewhere
      };
    };
  };
}
