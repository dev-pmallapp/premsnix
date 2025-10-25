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
          git = enabled;
          ssh = enabled;
        };
      };
    };

    services = {
      sops = {
        enable = true;
        defaultSopsFile = lib.getFile "secrets/premsnix/pmallapp/default.yaml";
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };

    system = {
      xdg = enabled;
    };

    suites = {
      common = enabled;
      development = enabled;
    };
  };

  home.stateVersion = "25.11";
}
