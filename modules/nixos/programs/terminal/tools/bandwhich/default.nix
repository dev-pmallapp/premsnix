{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.tools.bandwhich;
in
{
  options.premunix.programs.terminal.tools.bandwhich = {
    enable = lib.mkEnableOption "bandwhich";
  };

  config = mkIf cfg.enable {
    programs.bandwhich = {
      enable = true;
    };
  };
}
