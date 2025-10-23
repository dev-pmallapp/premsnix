{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.terminal.tools.azure;
in
{
  options.premunix.programs.terminal.tools.azure = {
    enable = lib.mkEnableOption "common Azure utilities";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        azure-cli
        azure-functions-core-tools
        azure-storage-azcopy
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ azuredatastudio ];
  };
}
