{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;
in
{
  imports = [
    # TODO:
    # ./disks.nix
    ./hardware.nix
  ];

  premsnix = {
    nix = enabled;

    archetypes = {
      server = enabled;
    };

    hardware = {
      audio = enabled;
      bluetooth = enabled;
      cpu.intel = enabled;
      opengl = enabled;

      storage = {
        enable = true;
        ssdEnable = true;
        zfs = enabled;
      };
    };

    services = {
      # avahi = enabled;
      geoclue = enabled;
      printing = enabled;
      openssh = enabled;

      # TODO: Set up shares
      samba = {
        enable = true;

        shares = {
          games = {
            browsable = true;
            comment = "Games folder";
            only-owner-editable = true;
            path = "/mnt/games/";
            public = true;
            read-only = false;
          };

          # Application data folder
          appData = {
            browsable = true;
            comment = "Application Data folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/.config/";
            public = false;
            read-only = false;
          };

          # Data folder
          data = {
            browsable = true;
            comment = "Data folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/.local/share/";
            public = false;
            read-only = false;
          };

          # Virtual Machines folder
          vms = {
            browsable = true;
            comment = "Virtual Machines folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/vms/";
            public = false;
            read-only = false;
          };

          # ISO images folder
          isos = {
            browsable = true;
            comment = "ISO Images folder";
            only-owner-editable = true;
            path = "/home/${config.premsnix.user.name}/isos/";
            public = false;
            read-only = false;
          };

          # Time Machine backups folder
          timeMachine = {
            browsable = true;
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
        defaultSopsFile = lib.getFile "secrets/nuc-v09/default.yaml";
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
    };
  };

  # Define system user for parity with image build expectations (avoids assertion)
  users.users.nixos = {
    isSystemUser = true;
    group = "nixos";
  };
  users.groups.nixos = { };

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
}
