{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.tools.dircolors;
in
{
  options.premsnix.programs.terminal.tools.dircolors = {
    enable = lib.mkEnableOption "dircolors";
  };

  config = mkIf cfg.enable {
    programs.dircolors = {
      enable = true;
    };
  };
}
