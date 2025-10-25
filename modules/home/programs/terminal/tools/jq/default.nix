{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.tools.jq;
in
{
  options.premsnix.programs.terminal.tools.jq = {
    enable = lib.mkEnableOption "jq";
  };

  config = mkIf cfg.enable {
    programs.jq = {
      enable = true;
      package = pkgs.jq;
    };
  };
}
