{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "mmc_block"
      ];
    };

    extraModulePackages = [ ];

    kernelParams = [
      "console=ttyAMA0,115200"
      "console=tty1"
      "cma=256M"
    ];

    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "noatime"
        "nodiratime"
      ];
    };

    "/boot" = lib.mkForce {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "umask=0077"
      ];
    };
  };

  swapDevices = [ ];

  hardware = {
    deviceTree = {
      enable = true;
      filter = "bcm2711-rpi-4-b.dtb";
    };

    enableRedistributableFirmware = true;
  };

  networking.useDHCP = lib.mkDefault true;
}
