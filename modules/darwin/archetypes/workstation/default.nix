{
  config,
  lib,

  ...
}:
let
  inherit (lib.premunix) enabled;

  cfg = config.premunix.archetypes.workstation;
in
{
  options.premunix.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      taps = [
        "deskflow/homebrew-tap"
      ];
      casks = [ "deskflow" ];
    };

    premunix = {
      suites = {
        business = enabled;
        common = enabled;
        desktop = enabled;
        development = enabled;
      };
    };
  };
}
