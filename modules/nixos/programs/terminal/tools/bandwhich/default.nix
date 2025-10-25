{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.tools.bandwhich;
in
{
  options.premsnix.programs.terminal.tools.bandwhich = {
    enable = lib.mkEnableOption "bandwhich";
  };

  config = mkIf cfg.enable {
    programs.bandwhich = {
      enable = true;
    };
  };
}
