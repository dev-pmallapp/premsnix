{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.archetypes.personal;
in
{
  options.premsnix.archetypes.personal = {
    enable = lib.mkEnableOption "the personal archetype";
  };

  config = mkIf cfg.enable {
    premsnix = {
      services = {
        tailscale = enabled;
      };

      suites = {
        common = enabled;
      };
    };

    # Personal archetype adds fun/toy packages removed from the slim common suite
    environment.systemPackages = with config.pkgs; [
      fortune
      lolcat
    ];
  };
}
