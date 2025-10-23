{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.common;
in
{
  options.premunix.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      coreutils
      curl
      fd
      file
      findutils
      killall
      lsof
      pciutils
      pkgs.premunix.trace-symlink
      pkgs.premunix.trace-which
      pkgs.premunix.why-depends
      tldr
      unzip
      wget
      xclip
    ];
  };
}
