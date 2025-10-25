{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.programs.terminal.tools.direnv;
in
{
  options.premsnix.programs.terminal.tools.direnv = {
    enable = lib.mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv = enabled;
      silent = true;
    };
  };
}
