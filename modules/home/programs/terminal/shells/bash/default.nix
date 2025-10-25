{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.shell.bash;
in
{
  options.premsnix.programs.terminal.shell.bash = {
    enable = lib.mkEnableOption "bash";
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;

      initExtra = lib.optionalString config.programs.fastfetch.enable ''
        fastfetch
      '';
    };
  };
}
