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
      enable = true;
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
      gpg = enabled;
    };

    services = {
      openssh = enabled;
      power.enable = mkForce false;
      printing.enable = false;
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
    };

    suites.common.enable = true;
    theme.stylix.enable = false;
    programs.graphical = {
      # Explicitly disable graphical components for headless Pi usage
      wms = {
        sway.enable = false;
        hyprland.enable = false;
      };
      bars = {
        waybar.enable = false;
        ashell.enable = false;
        sketchybar.enable = false;
      };
      screenlockers.swaylock.enable = false;
      desktop-environment.gnome.enable = false;
      apps = {
        discord.enable = false;
      };
      addons = {
        satty.enable = false;
        noisetorch.enable = false;
      };
      browsers.firefox.enable = false;
    };
    programs = {
      networking = {
        tools = {
          enable = true;
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
