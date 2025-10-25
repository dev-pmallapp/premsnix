{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.workstation;
in
{
  options.premsnix.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      taps = [
        "deskflow/homebrew-tap"
      ];
      casks = [ "deskflow" ];
    };

    premsnix = {
      suites = {
        business = enabled;
        common = enabled;
        desktop = enabled;
        development = enabled;
      };
    };
  };
}
