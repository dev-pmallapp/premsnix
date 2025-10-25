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
        # Use a system-scoped key location to avoid dependency on user home existing at evaluation
        keyFile = "/var/lib/sops-nix/keys.txt";
        generateKey = true;
      };
    };

    sops.secrets = {
      "premsnix_pmallapp_ssh_key" = {
        sopsFile = lib.getFile "secrets/premsnix/pmallapp/default.yaml";
      };
    };
  };
}
