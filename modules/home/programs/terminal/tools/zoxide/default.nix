{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.tools.zoxide;
in
{
  options.premsnix.programs.terminal.tools.zoxide = {
    enable = lib.mkEnableOption "zoxide";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      package = pkgs.zoxide;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      options = [ "--cmd cd" ];
    };
  };
}
