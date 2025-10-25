{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption optionalAttrs;
  cfg = config.premsnix.security.openssh.managedKeys;
  username = config.premsnix.user.name or "pmallapp";
  host = config.networking.hostName;

  # Resolve a repository-relative path (if it exists) returning a path value or null.
  safeGet =
    rel:
    let
      p = ./. + "/" + rel;
    in
    if builtins.pathExists p then p else null;

  hostSecretPath =
    if cfg.manageHostKey then
      let
        primary = safeGet "secrets/hosts/${host}/ssh_host_ed25519_key";
      in
      if primary != null then primary else safeGet "secrets/${host}/ssh_host_ed25519_key"
    else
      null;
  userAuthKeysPath =
    if cfg.manageUserAuthorizedKeys then
      let
        primary = safeGet "secrets/users/${username}/authorized_keys";
      in
      if primary != null then primary else safeGet "secrets/${username}/authorized_keys"
    else
      null;
  knownHostsPath =
    if cfg.manageKnownHosts then
      let
        primary = safeGet "secrets/known_hosts";
      in
      if primary != null then primary else safeGet "secrets/ssh_known_hosts"
    else
      null;
in
{
  options.premsnix.security.openssh.managedKeys = {
    enable = mkEnableOption "Manage host/user ssh keys & known_hosts via sops secrets (pure-eval safe)";
    manageHostKey = mkEnableOption "Provide host ed25519 key from sops";
    manageUserAuthorizedKeys = mkEnableOption "Provide user authorized_keys from sops";
    manageKnownHosts = mkEnableOption "Provide global known_hosts file from sops";
  };

  config = mkIf (cfg.enable && config.premsnix.security.sops.enable) {
    # Secret declarations (only emit entries when paths resolve)
    sops.secrets =
      (optionalAttrs (cfg.manageHostKey && hostSecretPath != null) {
        ssh_host_ed25519_key = {
          sopsFile = hostSecretPath;
          mode = "0600";
          owner = "root";
          group = "root";
        };
      })
      // (optionalAttrs (cfg.manageUserAuthorizedKeys && userAuthKeysPath != null) {
        "authorized_keys_${username}" = {
          sopsFile = userAuthKeysPath;
          mode = "0600";
          owner = username;
          group = config.users.users.${username}.group or "users";
        };
      })
      // (optionalAttrs (cfg.manageKnownHosts && knownHostsPath != null) {
        ssh_known_hosts = {
          sopsFile = knownHostsPath;
          mode = "0644";
          owner = "root";
          group = "root";
        };
      });

    # Instead of referencing /run secret paths directly in options that pure eval checks, materialize them into /etc.
    environment.etc =
      (optionalAttrs (cfg.manageHostKey && hostSecretPath != null) {
        "ssh/ssh_host_ed25519_key".source = config.sops.secrets.ssh_host_ed25519_key.path;
      })
      // (optionalAttrs (cfg.manageUserAuthorizedKeys && userAuthKeysPath != null) {
        "ssh/authorized_keys.d/${username}".source = config.sops.secrets."authorized_keys_${username}".path;
      })
      // (optionalAttrs (cfg.manageKnownHosts && knownHostsPath != null) {
        "ssh/ssh_known_hosts".source = config.sops.secrets.ssh_known_hosts.path;
      });

    # Rely on default host key discovery from /etc/ssh instead of explicit services.openssh.hostKeys list.
    # Add known hosts via static /etc path to stay pure-eval safe.
    programs.ssh.knownHostsFiles = mkIf (cfg.manageKnownHosts && knownHostsPath != null) [
      "/etc/ssh/ssh_known_hosts"
    ];
  };
}
