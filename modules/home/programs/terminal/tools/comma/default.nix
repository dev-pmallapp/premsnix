{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.tools.comma;
in
{
  options.premsnix.programs.terminal.tools.comma = {
    enable = lib.mkEnableOption "comma";
  };

  config = mkIf cfg.enable {
    programs = {
      nix-index-database.comma.enable = true;

      nix-index = {
        enable = true;
        package = pkgs.nix-index;

        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;

        # link nix-inde database to ~/.cache/nix-index
        symlinkToCacheHome = true;
      };
    };
  };
}
