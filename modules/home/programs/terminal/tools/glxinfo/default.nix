{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.tools.glxinfo;
in
{
  options.premunix.programs.terminal.tools.glxinfo = {
    enable = lib.mkEnableOption "glxinfo";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ mesa-demos ]; };
}
