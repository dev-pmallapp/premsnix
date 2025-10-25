{
  lib,
  config,
  ...
}:
let
  inherit (lib.premsnix) enabled;
  cfg = config.premsnix.user;
  newSecret = lib.getFile "secrets/mac/default.yaml"; # reuse shared secret path or specialize later
  legacySecret = lib.getFile "secrets/khanelimac/default.yaml";
  defaultSopsFile = if builtins.pathExists newSecret then newSecret else legacySecret;
in
{
  premsnix = {
    security = {
      sudo = enabled;
      sops = {
        enable = true;
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        inherit defaultSopsFile;
      };
    };

    suites = {
      common = enabled;
      development = enabled;
      networking = enabled;
    };

    tools.homebrew.enable = false;
  };

  networking = {
    computerName = "Austins MacBook Pro Build Machine";
    hostName = "mac-m1";
    localHostName = "mac-m1";
    knownNetworkServices = [
      "ThinkPad TBT 3 Dock"
      "Wi-Fi"
      "Thunderbolt Bridge"
    ];
    wakeOnLan = enabled;
  };

  nix.settings = {
    cores = 10;
    max-jobs = 3;
  };

  # Authorized keys now provided via sops managed module (premsnix.security.openssh.managedKeys)
  users.users.${cfg.name} = { };

  system = {
    primaryUser = "pmallapp";
    stateVersion = 5;
  };
}
