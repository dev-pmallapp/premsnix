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
        defaultSopsFile = lib.getFile "secrets/khanelimac/pmallapp/default.yaml";
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
