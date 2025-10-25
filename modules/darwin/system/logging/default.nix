{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premsnix.system.logging;
in

{
  imports = [
    ./newsyslog.nix
  ];

  options.premsnix.system.logging = {
    enable = mkEnableOption "system logging configuration";
  };

  config = mkIf cfg.enable {
    system.newsyslog = {
      enable = true;
    };
  };
}
