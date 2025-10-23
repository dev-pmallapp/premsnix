{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.premunix.programs.terminal.media.ncspot;
in
{
  options.premunix.programs.terminal.media.ncspot = {
    enable = mkEnableOption "ncspot";
  };

  config = mkIf cfg.enable {
    programs.ncspot = {
      enable = true;

      settings = { };
    };
  };
}
