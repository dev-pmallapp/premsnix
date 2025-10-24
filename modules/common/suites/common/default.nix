{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.suites.common;
in
{
  options.premsnix.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    environment = {
      defaultPackages = lib.mkForce [ ];

      systemPackages =
        let
          base = with pkgs; [
            coreutils
            curl
            fd
            file
            findutils
            killall
            lsof
            pciutils
            pkgs.premsnix.trace-symlink
            pkgs.premsnix.trace-which
            pkgs.premsnix.why-depends
            tldr
            unzip
            wget
            # xclip removed for headless minimal systems
          ];
        in
        base ++ lib.optionals (!pkgs.stdenv.hostPlatform.isAarch64) [ pkgs.usbimager ];
    };
  };
}
