{ lib, ... }:
{
  options.premsnix.hardware.cpu = {
    enable = lib.mkEnableOption "No-op used for setting up hierarchy";
  };
}
