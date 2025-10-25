{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.security.sops;
in
{
  options.premsnix.security.sops = {
    enable = lib.mkEnableOption "sops";
    defaultSopsFile = mkOpt lib.types.path null "Default sops file.";
    sshKeyPaths = mkOpt (with lib.types; listOf path) [
      "/etc/ssh/ssh_host_ed25519_key"
    ] "SSH Key paths to use.";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      inherit (cfg) defaultSopsFile;

      age = {
        inherit (cfg) sshKeyPaths;

        keyFile = "${config.users.users.${config.premsnix.user.name}.home}/.config/sops/age/keys.txt";
      };
    };

    sops.secrets = {
      "mac_pmallapp_ssh_key" = {
        # Legacy khanelimac fallback removed; only new path supported now
        sopsFile = lib.getFile "secrets/mac/pmallapp/default.yaml";
      };
    };
  };
}
