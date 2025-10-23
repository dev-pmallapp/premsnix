{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.graphical.apps.partitionmanager;
in
{
  options.premunix.programs.graphical.apps.partitionmanager = {
    enable = lib.mkEnableOption "partitionmanager";
  };

  config = mkIf cfg.enable {
    programs.partition-manager = {
      enable = true;
      package = pkgs.kdePackages.partitionmanager;
    };
  };
}
