_:
let
  device = "/dev/mmcblk0";
in
{
  # GPT layout replacing legacy msdos/table for better tooling compatibility.
  # First partition: FAT32 firmware (/boot) labeled FIRMWARE.
  # Second partition: ext4 root labeled NIXOS_SD.
  disko.devices = {
    disk = {
      sdCard = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            firmware = {
              priority = 1;
              start = "4MiB";
              end = "516MiB";
              type = "EF00"; # EFI type (harmless on Pi, keeps tooling happy)
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-n"
                  "FIRMWARE"
                ];
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              priority = 2;
              start = "516MiB";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-F"
                  "-L"
                  "NIXOS_SD"
                ];
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                  "nodiratime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
