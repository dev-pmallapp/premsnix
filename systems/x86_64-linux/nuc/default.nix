{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkForce;
  inherit (lib.premsnix) enabled;
  # Prefer CORE secret if present, fallback to legacy nuc-v09 path
  coreSecret = lib.getFile "secrets/CORE/nixos/default.yaml";
  legacySecret = lib.getFile "secrets/nuc-v09/default.yaml";
  defaultSopsFile = if builtins.pathExists coreSecret then coreSecret else legacySecret;
in
{
  imports = [
    # Retain existing hardware layout from v09 (bare metal). For WSL-like usage, layer via specialization.
    ../nuc-v09/hardware.nix
    # Optional: ../nuc-v09/disks.nix  # Uncomment if disko provisioning desired
  ];

  # Consolidated system archetypes: server base + development capabilities
  premsnix = {
    nix = enabled;

    archetypes = {
      server = enabled;
      # Add workstation or gaming here if GUI / GPU stack needed
    };

    hardware = {
      audio = enabled;
      bluetooth = enabled;
      cpu.intel = enabled;
      opengl = enabled;
      yubikey = enabled; # from nuc-v11
      storage = {
        enable = true;
        ssdEnable = true;
        zfs = enabled;
      };
    };

    services = {
      geoclue = enabled;
      openssh = enabled;
      samba = {
        enable = true;
        shares = {
          games = {
            browseable = true; # spelling per Samba option; allowed via typos.toml
            comment = "Games folder";
            only-owner-editable = true;
            path = "/mnt/games/";
            public = true;
            read-only = false;
          };
          appData = {
            browseable = true; # Samba option name
            comment = "Application Data folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/.config/";
            public = false;
            read-only = false;
          };
          data = {
            browseable = true; # Samba option name
            comment = "Data folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/.local/share/";
            public = false;
            read-only = false;
          };
          vms = {
            browseable = true; # Samba option name
            comment = "Virtual Machines folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/vms/";
            public = false;
            read-only = false;
          };
          isos = {
            browseable = true; # Samba option name
            comment = "ISO Images folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/isos/";
            public = false;
            read-only = false;
          };
          timeMachine = {
            browseable = true; # Samba option name
            comment = "Time Machine backups folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/.timemachine/";
            public = false;
            read-only = true;
          };
        };
      };
    };

    security = {
      doas = enabled;
      keyring = enabled;
      sops = {
        enable = true;
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        inherit defaultSopsFile;
      };
    };

    system = {
      boot = {
        enable = true;
        secureBoot = true;
      };
      fonts = enabled;
      networking = enabled;
      time = enabled;
    };

    suites = {
      common = enabled;
      development = {
        enable = true;
        sqlEnable = true;
      };
      virtualisation = {
        enable = true;
        dockerEnable = true;
      };
    };

    user.name = "nixos";
  };

  # Provide system user (image parity)
  users.users.nixos = lib.mkForce {
    isSystemUser = true;
    group = "users"; # align with primary user group to avoid conflict
  };

  # Network config merged from nuc-v09 (static). Adjust or override via deployment host.
  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = "eth0";
    };
    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.1.37";
        prefixLength = 24;
      }
    ];
  };

  system.stateVersion = "25.11";

  # Specialization for WSL-like environment (optional)
  specialisation.wsl.configuration = {
    imports = [ ../nuc-v11/hardware.nix ];
    premsnix = {
      archetypes.wsl = enabled;
      security.gpg.enable = mkForce false;
    };
    # Resolve conflicting man pages enable by preferring minimal profile disable
    documentation.man.enable = lib.mkForce false;
    # Avoid bootloader conflicts inside WSL specialization
    boot = {
      loader = {
        grub.enable = lib.mkForce false;
        systemd-boot.enable = lib.mkForce false;
        external.enable = lib.mkForce false;
      };
      bootspec.enable = lib.mkForce false;
      # Lanzaboote secure boot not relevant in WSL
      lanzaboote.enable = lib.mkForce false;
    };
  };
}
