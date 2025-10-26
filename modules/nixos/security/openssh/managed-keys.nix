{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalAttrs;
  cfg = config.premsnix.security.openssh.managedKeys;
  username = config.premsnix.user.name or "pmallapp";
  host = config.networking.hostName;

  # Resolve a repository-relative path (flake root) returning a path or null.
  safeGet =
    rel:
    let
      p = inputs.self + "/" + rel;
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
    strict = mkEnableOption "Fail evaluation (assert) instead of warn when required managed secrets are missing";
    warnMissing = mkEnableOption "Emit evaluation warnings when managed secrets are missing (ignored if strict=true)";
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

    # Soft warnings (when strict=false and warnMissing=true)
    warnings = mkIf (!cfg.strict && cfg.warnMissing) (
      (lib.optional (cfg.manageUserAuthorizedKeys && userAuthKeysPath == null)
        "premsnix.openssh.managedKeys: manageUserAuthorizedKeys enabled but no secret file found at secrets/users/${username}/authorized_keys or secrets/${username}/authorized_keys"
      )
      ++ (lib.optional (cfg.manageHostKey && hostSecretPath == null)
        "premsnix.openssh.managedKeys: manageHostKey enabled but no secret file found for host ${host} (expected secrets/hosts/${host}/ssh_host_ed25519_key or secrets/${host}/ssh_host_ed25519_key)"
      )
      ++ (lib.optional (cfg.manageKnownHosts && knownHostsPath == null)
        "premsnix.openssh.managedKeys: manageKnownHosts enabled but secrets/known_hosts (or secrets/ssh_known_hosts) not found"
      )
    );

    assertions = lib.optionals cfg.strict [
      {
        assertion = !(cfg.manageUserAuthorizedKeys && userAuthKeysPath == null);
        message = "premsnix.openssh.managedKeys(strict): manageUserAuthorizedKeys enabled but required secret missing for ${username}";
      }
      {
        assertion = !(cfg.manageHostKey && hostSecretPath == null);
        message = "premsnix.openssh.managedKeys(strict): manageHostKey enabled but required host key secret missing for ${host}";
      }
      {
        assertion = !(cfg.manageKnownHosts && knownHostsPath == null);
        message = "premsnix.openssh.managedKeys(strict): manageKnownHosts enabled but no known_hosts secret present";
      }
    ];
  };
}
