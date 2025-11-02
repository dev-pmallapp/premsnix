{
  lib,
  config,
  ...
}:
let
  inherit (lib.premsnix) enabled;
  cfg = config.premsnix.user;
  # Fallback to legacy secret path if new path not yet migrated
  newSecret = lib.getFile "secrets/mac/default.yaml";
  legacySecret = lib.getFile "secrets/imac/default.yaml";
  defaultSopsFile = if builtins.pathExists newSecret then newSecret else legacySecret;
in
{
  premsnix = {
    archetypes = {
      personal = enabled;
      workstation = enabled;
    };

    security = {
      sudo = enabled;
      sops = {
        enable = true;
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        inherit defaultSopsFile;
      };
    };

    suites = {
      art = enabled;
      common = enabled;
      desktop = enabled;
      development = {
        enable = true;
        aiEnable = true;
      };
      games = enabled;
      music = enabled;
      networking = enabled;
      social = enabled;
      video = enabled;
      vm = enabled;
    };

    system.logging = enabled;
    tools.homebrew.masEnable = true;
  };

  environment.systemPath = [ "/opt/homebrew/bin" ];

  networking = {
    computerName = "Austins MacBook Pro";
    hostName = "mac";
    localHostName = "mac";
    knownNetworkServices = [
      "ThinkPad TBT 3 Dock"
      "Wi-Fi"
      "Thunderbolt Bridge"
    ];
  };

  nix.settings = {
    cores = 16;
    max-jobs = 8;
  };

  # Authorized keys now provided via sops managed module (premsnix.security.openssh.managedKeys)
  users.users.${cfg.name} = { };

  system = {
    primaryUser = "pmallapp";
    stateVersion = 5;
  };
}
