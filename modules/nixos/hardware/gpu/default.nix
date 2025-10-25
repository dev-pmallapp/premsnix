{ lib, ... }:
{
  options.premsnix.hardware.gpu = {
    enable = lib.mkEnableOption "No-op for setting up hierarchy";
  };
}
