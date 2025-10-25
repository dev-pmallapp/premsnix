{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.photo;
in
{
  options.premsnix.suites.photo = {
    enable = lib.mkEnableOption "photo configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      lib.optionals stdenv.hostPlatform.isLinux [
        darktable
        digikam
        exiftool
        shotwell
      ];
  };
}
