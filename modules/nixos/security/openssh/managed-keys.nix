{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption getFile;
  cfg = config.premsnix.security.openssh.managedKeys;
  username = config.premsnix.user.name or "pmallapp";
  host = config.networking.hostName;

  # Helper resolving new > legacy path
  fallback = new: legacy: if builtins.pathExists new then new else legacy;

  hostSecretPath = fallback (getFile "secrets/hosts/${host}/ssh_host_ed25519_key") (
    getFile "secrets/${host}/ssh_host_ed25519_key"
  );
  userAuthKeysPath = fallback (getFile "secrets/users/${username}/authorized_keys") (
    getFile "secrets/${username}/authorized_keys"
  );
  knownHostsPath = fallback (getFile "secrets/known_hosts") (getFile "secrets/ssh_known_hosts");
in
{
  options.premsnix.security.openssh.managedKeys = {
    enable = mkEnableOption "Manage host/user ssh keys & known_hosts via sops secrets";
    manageHostKey = mkEnableOption "Provide host ed25519 key from sops";
    manageUserAuthorizedKeys = mkEnableOption "Provide user authorized_keys from sops";
    manageKnownHosts = mkEnableOption "Provide global known_hosts file from sops";
  };

  config = mkIf cfg.enable (
    mkIf config.premsnix.security.sops.enable {
      # Secrets definitions
      sops.secrets =
        (lib.optionalAttrs cfg.manageHostKey {
          ssh_host_ed25519_key = {
            sopsFile = hostSecretPath;
            mode = "0600";
            owner = "root";
            group = "root";
          };
        })
        // (lib.optionalAttrs cfg.manageUserAuthorizedKeys {
          "authorized_keys_${username}" = {
            sopsFile = userAuthKeysPath;
            mode = "0600";
            owner = username;
            group = config.users.users.${username}.group or "users";
          };
        })
        // (lib.optionalAttrs cfg.manageKnownHosts {
          ssh_known_hosts = {
            sopsFile = knownHostsPath;
            mode = "0644";
            owner = "root";
            group = "root";
          };
        });

      # Wire host key into sshd
      services.openssh.hostKeys = mkIf cfg.manageHostKey [
        {
          inherit (config.sops.secrets.ssh_host_ed25519_key) path;
          type = "ed25519";
        }
      ];

      # User authorized_keys file support
      users.users.${username}.openssh.authorizedKeys.keyFiles = lib.mkIf cfg.manageUserAuthorizedKeys [
        config.sops.secrets."authorized_keys_${username}".path
      ];

      # Global known hosts (system ssh + can be imported by HM layer)
      programs.ssh.knownHostsFiles = lib.mkIf cfg.manageKnownHosts [
        config.sops.secrets.ssh_known_hosts.path
      ];
    }
  );
}
