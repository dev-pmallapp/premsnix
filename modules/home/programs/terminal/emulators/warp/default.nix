{
  config,
  pkgs,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.emulators.warp;

in
{
  options.premunix.programs.terminal.emulators.warp = {
    enable = lib.mkEnableOption "warp";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ warp-terminal ];

  };
}
