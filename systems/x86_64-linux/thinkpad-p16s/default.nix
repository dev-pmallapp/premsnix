{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;
  secretsCandidate = ../../../secrets/thinkpad-p16s/default.yaml;
  hasHostSecrets = builtins.pathExists secretsCandidate;
  defaultSopsFile =
    if hasHostSecrets then secretsCandidate else lib.getFile "secrets/premsnix/pmallapp/default.yaml";
in
{
  imports = [
    ./disks.nix
    ./hardware.nix
    ./network.nix
    # ./specializations.nix
  ];

  premsnix = {
    nix = enabled;

    archetypes = {
      gaming = enabled;
      personal = enabled;
    };

    display-managers = {
      gdm = {
        defaultSession = "gnome";
      };
    };

    hardware = {
      audio = {
        enable = true;
      };

      bluetooth = enabled;
      cpu.amd = enabled;
      gpu.amd = enabled;
      opengl = enabled;
      rgb.openrgb.enable = true;

      storage = {
        enable = true;
        ssdEnable = true;
      };

      tpm = enabled;
    };

    programs = {
      graphical = {
        desktop-environment = {
          gnome = {
            enable = true;
          };
        };
      };
    };

    services = {
      avahi = enabled;
      geoclue = enabled;
      power = enabled;
      printing = enabled;

      openssh = {
        enable = true;

        # TODO: make part of ssh config proper
        extraConfig = ''
          Host server
            User ${config.premsnix.user.name}
            Hostname austinserver.local
        '';
      };
    };

    security = {
      keyring = enabled;
      sudo-rs = enabled;
      sops = {
        enable = true;
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        inherit defaultSopsFile;
      };
      openssh.managedKeys = {
        enable = true;
        manageHostKey = true;
        manageKnownHosts = true;
        # secrets/users/pmallapp/authorized_keys now expected; enable management
        manageUserAuthorizedKeys = true;
        warnMissing = false; # silence missing-secret warnings until secrets committed
      };
    };

    system = {
      boot = {
        enable = true;
        # TODO: configure
        # secureBoot = true;
        plymouth = true;
        silentBoot = true;
      };

      fonts = enabled;
      locale = enabled;
      networking = {
        enable = true;
        optimizeTcp = true;
      };
      realtime = enabled;
      time = enabled;
    };

    theme = {
      # gtk = enabled;
      # qt = enabled;
      stylix = enabled;
    };

    user.name = "pmallapp";
  };

  environment.variables = {
    # Fix black bars in gnome
    GSK_RENDERER = "ngl";
    # Fix mouse pointer in gnome
    NO_POINTER_VIEWPORT = "1";
  };

  nix.settings = {
    cores = 8;
    max-jobs = 8;
  };

  services = {
    mpd = {
      musicDirectory = "nfs://austinserver.local/mnt/user/data/media/music";
    };
    rpcbind.enable = true; # needed for NFS
  };

  system.stateVersion = "25.11";
  # Provide system 'nixos' user to satisfy assertions for modules expecting its presence
  # 'nixos' user now defined as normal user with initial password in dual-users module.
}
