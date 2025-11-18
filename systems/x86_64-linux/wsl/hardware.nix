{
  ...
}:
{
  hardware = {
    cpu.amd.updateMicrocode = false;
    cpu.intel.updateMicrocode = false;
    enableRedistributableFirmware = false;
  };

  # WSL doesn't support traditional hardware detection
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
}
