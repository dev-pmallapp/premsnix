{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.hardware.gpu.amd;
in
{
  options.premunix.hardware.gpu.amd = {
    enable = lib.mkEnableOption "support for amdgpu";
    enableRocmSupport = lib.mkEnableOption "support for rocm";
    enableNvtop = lib.mkEnableOption "install nvtop for amd";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        amdgpu_top
      ]
      ++ lib.optionals cfg.enableNvtop [
        nvtopPackages.amd
      ];

    # enables AMDVLK & OpenCL support
    hardware = {
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
        overdrive.enable = true;
      };

      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vulkan-tools
        ];
      };
    };

    nixpkgs.config.rocmSupport = cfg.enableRocmSupport;
  };
}
