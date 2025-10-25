{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.premsnix.suites.virtualisation;
in
{
  options.premsnix.suites.virtualisation = with lib; {
    enable = mkEnableOption "virtualisation suite aggregator";
    podmanEnable = mkEnableOption "enable podman (rootless-capable OCI)";
    dockerEnable = mkEnableOption "enable docker engine (mutually exclusive with podman socket clash if both)";
    kvmEnable = mkEnableOption "enable KVM/libvirtd (QEMU accelerated)";
    qemuEnable = mkEnableOption "add standalone qemu utilities";
    virtualboxEnable = mkEnableOption "enable VirtualBox host modules";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # Podman & Docker integration
        premsnix.virtualisation.podman.enable = lib.mkDefault cfg.podmanEnable;

        virtualisation = {
          docker.enable = lib.mkDefault cfg.dockerEnable;
        };

        # libvirtd / KVM
        premsnix.virtualisation.kvm.enable = lib.mkDefault cfg.kvmEnable;

        # Standalone QEMU tools if requested without full libvirtd stack
        environment.systemPackages = lib.optionals (cfg.qemuEnable && !cfg.kvmEnable) [ pkgs.qemu_kvm ];

        # VirtualBox
        virtualisation.virtualbox.host.enable = lib.mkDefault cfg.virtualboxEnable;
        users.extraGroups.vboxusers.members = lib.mkIf cfg.virtualboxEnable [ config.premsnix.user.name ];
      }
      {
        assertions = [
          {
            assertion = !(cfg.dockerEnable && cfg.podmanEnable);
            message = "podmanEnable and dockerEnable are both true; pick one to provide the docker socket.";
          }
        ];
      }
    ]
  );
}
