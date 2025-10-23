{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.suites.vm;
in
{
  options.premunix.suites.vm = {
    enable = lib.mkEnableOption "vm";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # FIX: broken nixpkg on darwin
      # qemu
      vte
      # FIX: broken nixpkg on darwin
      # libvirt
    ];

    homebrew = {
      casks = [ "utm" ];
    };
  };
}
