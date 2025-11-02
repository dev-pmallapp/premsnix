{ lib, ... }:
let
  inherit (lib.premsnix) enabled;
  defaultSopsFile = lib.getFile "secrets/premsnix/pmallapp/default.yaml";
in
{
  imports = [ ./hardware.nix ];

  programs.sway.extraSessionCommands = # bash
    ''
      WLR_NO_HARDWARE_CURSORS=1
    '';

  premsnix = {
    nix = enabled;

    archetypes = {
      vm = enabled;
    };

    programs = {
      graphical = {
        apps = {
          _1password = enabled;
        };

        wms = {
          hyprland = {
            enable = true;
          };
        };
      };
    };

    services = {
      printing = enabled;
    };

    security = {
      doas = enabled;
      keyring = enabled;
      sops = {
        enable = true;
        inherit defaultSopsFile;
      };
      openssh.managedKeys = {
        enable = true;
        manageHostKey = true;
        manageKnownHosts = true;
        manageUserAuthorizedKeys = true;
        strict = true;
      };
    };

    system = {
      boot = enabled;
      fonts = enabled;
      locale = enabled;
      networking = enabled;
      time = enabled;
      xkb = enabled;
    };
  };

  services.displayManager.defaultSession = "hyprland-uwsm";
  # Ensure implicit 'nixos' user satisfies assertion (mark as system user for VM image parity)
  # 'nixos' user is now provided as a normal user with an initial password by the dual-users module.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}
