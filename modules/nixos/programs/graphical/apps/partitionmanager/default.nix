{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.graphical.apps.partitionmanager;
in
{
  options.premsnix.programs.graphical.apps.partitionmanager = {
    enable = lib.mkEnableOption "partitionmanager";
  };

  config = mkIf cfg.enable {
    programs.partition-manager = {
      enable = true;
      package = pkgs.kdePackages.partitionmanager;
    };
  };
}
