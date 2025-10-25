{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.premsnix.services.jankyborders;
  userHome = config.users.users.${config.premsnix.user.name}.home;
in

{
  options.premsnix.services.jankyborders = {
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
        owner = config.premsnix.user.name;
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
