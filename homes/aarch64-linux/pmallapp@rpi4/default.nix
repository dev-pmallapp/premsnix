{
  config,
  lib,

  osConfig ? { },
  ...
}:
let
  inherit (lib.premsnix) enabled;
  secretsCandidate = ../../../secrets/premsnix/rpi4/default.yaml;
  hasHostSecrets = builtins.pathExists secretsCandidate;
  defaultSopsFile =
    if hasHostSecrets then secretsCandidate else lib.getFile "secrets/premsnix/pmallapp/default.yaml";
in
{
  premsnix = {
    user = {
      enable = true;
      name = "pmallapp";
    };

    programs = {
      terminal = {
        tools = {
          git = enabled;
          ssh = enabled;
        };
      };
    };

    services = {
      sops = {
        enable = true;
        inherit defaultSopsFile;
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };

    system = {
      xdg = enabled;
    };

    suites = {
      common = enabled;
    };
  };

  sops.secrets = lib.mkIf (osConfig.premsnix.security.sops.enable or false) {
    premsnix_pmallapp_ssh_key = { };
  };

  home.stateVersion = "25.11";
}
