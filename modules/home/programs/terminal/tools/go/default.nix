{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.tools.go;
in
{
  options.premunix.programs.terminal.tools.go = {
    enable = lib.mkEnableOption "Go support";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        go
        gopls
      ];

      sessionVariables = {
        GOPATH = "$HOME/work/go";
      };
    };
  };
}
