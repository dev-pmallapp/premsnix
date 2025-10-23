{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.tools.git-crypt;
in
{
  options.premunix.programs.terminal.tools.git-crypt = {
    enable = lib.mkEnableOption "git-crypt";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ git-crypt ]; };
}
