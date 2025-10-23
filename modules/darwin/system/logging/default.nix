{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.premunix.system.logging;
in

{
  imports = [
    ./newsyslog.nix
  ];

  options.premunix.system.logging = {
    enable = mkEnableOption "system logging configuration";
  };

  config = mkIf cfg.enable {
    system.newsyslog = {
      enable = true;
    };
  };
}
