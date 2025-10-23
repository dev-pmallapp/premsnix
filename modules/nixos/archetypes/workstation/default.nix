{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.workstation;
in
{
  options.premunix.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.deskflow
    ];

    premunix = {
      suites = {
        common = enabled;
        desktop = enabled;
        development = enabled;
      };
    };
  };
}
