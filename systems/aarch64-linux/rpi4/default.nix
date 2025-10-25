{
  lib,
  inputs,

  ...
}:
let
  inherit (lib)
    mkDefault
    mkForce
    optionalAttrs
    ;
  inherit (lib.premsnix) enabled;

  secretsCandidate = ../../../secrets/premsnix/rpi4/default.yaml;
  hasHostSecrets = builtins.pathExists secretsCandidate;
  wifiSecretName = "networkmanager/home.nmconnection";
  wifiConnectionTarget = "/etc/NetworkManager/system-connections/premsnix-home.nmconnection";
in
{
  imports = [
    ./hardware.nix
    ./disko.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  premsnix = {
    nix = enabled;
    archetypes.server = enabled;
    user.name = "pmallapp";
    hardware.storage = {
      # Disabled for minimal headless image to drop fs tooling (btrfs, ntfs3g, etc.)
      enable = false;
      ssdEnable = false;
    };
    hardware.fans.enable = mkForce false;

    security = {
      doas = enabled;
      sops = {
        enable = true;
        defaultSopsFile =
          if hasHostSecrets then secretsCandidate else lib.getFile "secrets/premsnix/pmallapp/default.yaml";
      };
      # TODO: Re-enable managed SSH keys once module avoids referencing /run paths during pure evaluation
      openssh.managedKeys.enable = false;
      gpg = enabled;
      keyring.enable = mkForce false;
      clamav.enable = mkForce false;
    };

    services = {
      openssh = enabled;
      power.enable = mkForce false;
      printing.enable = false;
      lact.enable = mkForce false;
      ddccontrol.enable = mkForce false;
    };

    system = {
      boot = {
        enable = true;
        secureBoot = mkForce false;
        silentBoot = false;
      };

      fonts.enable = false;
      networking = {
        enable = true;
        manager = "networkmanager";
      };
      time = enabled;
      # xdg.portal disable removed: not a valid NixOS premsnix.system.xdg option path; handled in home layer if needed
    };

    suites.common.enable = true;
    theme.stylix.enable = false;
    # Ensure we don't pull large desktop icon/sound themes explicitly (handled via home-manager, not a NixOS option)
    # home.packages override removed: incorrect scope (belongs to home-manager). Minimalism handled in home config.
    # Graphical stack intentionally omitted (headless Pi)
    programs = {
      networking = {
        tools = {
          enable = true;
          excludePackages = [
            "nmap"
            "rustscan"
            "hurl"
            "wakeonlan"
          ];
        };
      };
    };
  };

  # NixOS root user definition required by sd-image build
  users.users.nixos = {
    isSystemUser = true;
    group = "nixos";
  };
  users.groups.nixos = { };

  nixpkgs.hostPlatform = mkDefault "aarch64-linux";

  services.openssh.settings.PasswordAuthentication = false;

  # Disable upstream services not wrapped by premsnix.* modules here (headless minimal image)
  services = {
    fwupd.enable = lib.mkForce false;
    udisks2.enable = lib.mkForce false;
    upower.enable = lib.mkForce false;
  };

  # NetworkManager configuration (moved out of premsnix.system.networking which doesn't define a nested networkmanager attr)
  networking.networkmanager = {
    enable = true;
    plugins = [ ];
  };

  sops.secrets = optionalAttrs hasHostSecrets {
    "${wifiSecretName}" = {
      mode = "0600";
      owner = "root";
      group = "root";
      path = wifiConnectionTarget;
    };
  };

  systemd.tmpfiles.rules = [
    "d /etc/NetworkManager/system-connections 0700 root root -"
  ];

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = lib.mkForce false;
  };

  sdImage.compressImage = false;

  system.stateVersion = "25.11";
}
