{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) mkBoolOpt;

  cfg = config.premunix.hardware.storage;
in
{
  options.premunix.hardware.storage = {
    enable = lib.mkEnableOption "support for extra storage devices";
    ssdEnable = mkBoolOpt true "Whether or not to enable support for SSD storage devices.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btrfs-progs
      fuseiso
      nfs-utils
      ntfs3g
    ];

    services.fstrim.enable = lib.mkDefault cfg.ssdEnable;
  };
}
