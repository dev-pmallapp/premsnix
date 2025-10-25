{
  config,
  lib,

  ...
}:
let
  inherit (lib.premsnix) enabled;
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
          ssh = enabled;
        };
      };
    };

    services = {
      sops = {
        enable = true;
        # Removed legacy khanelimac fallback; only new mac path supported
        defaultSopsFile = lib.getFile "secrets/mac/pmallapp/default.yaml";
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };

    suites = {
      common = enabled;
      development = {
        enable = true;
        nixEnable = true;
      };
      networking = enabled;
    };

    theme.catppuccin = enabled;
  };

  home.stateVersion = "25.11";
}
