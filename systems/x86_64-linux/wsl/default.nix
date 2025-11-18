{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib.premsnix) enabled disabled;
  username = config.premsnix.user.name;
in
{
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  # WSL-specific system configuration
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = false;
    useWindowsDriver = false;
  };

  premsnix = {
    nix = enabled;

    # Minimal set of programs for WSL development environment
    programs = {
      shell = {
        zsh = enabled;
        starship = enabled;
      };

      cli = {
        git = enabled;
        nix-tools = enabled;
        ripgrep = enabled;
        fd = enabled;
        bat = enabled;
        fzf = enabled;
        jq = enabled;
        curl = enabled;
      };

      tui = {
        neovim = enabled;
        tmux = enabled;
      };

      dev = {
        direnv = enabled;
      };
    };

    suites = {
      minimal = enabled;
    };
  };

  # Basic system settings
  system = {
    stateVersion = "24.05";
    autoUpgrade.enable = false;
  };

  # WSL doesn't need heavy services
  services = {
    openssh.enable = false;
    acpid.enable = false;
    thermald.enable = false;
  };

  # Minimal boot configuration for WSL
  boot = {
    isContainer = true;
    loader.grub.enable = false;
    initrd.enable = false;
  };

  # Disable graphics
  hardware.graphics.enable = false;

  # Minimal filesystem setup
  fileSystems = {
    "/" = {
      device = "rootfs";
      fsType = "tmpfs";
      options = [ "size=100%" ];
    };
  };

  # User setup handled by config.premsnix.user
  # WSL integration
  environment.systemPackages = with pkgs; [
    git
    nix
    cacert
  ];

  networking = {
    hostName = "wsl";
    useNetworkd = true;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
}
