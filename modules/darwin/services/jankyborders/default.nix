{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.premunix.services.jankyborders;
  userHome = config.users.users.${config.premunix.user.name}.home;
in

{
  options.premunix.services.jankyborders = {
    enable = lib.mkEnableOption "jankyborders log rotation";

    logPath = mkOption {
      type = types.str;
      default = "${userHome}/Library/Logs/jankyborders.log";
      description = "Path to jankyborders log file";
    };
  };

  config = mkIf cfg.enable {
    system.newsyslog.files.jankyborders = [
      {
        logfilename = cfg.logPath;
        mode = "644";
        owner = config.premunix.user.name;
        group = "staff";
        count = 7;
        size = "2048";
        flags = [
          "Z"
          "C"
        ];
      }
    ];
  };
}
