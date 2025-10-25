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
        defaultSopsFile = lib.getFile "secrets/nuc-v09/default.yaml";
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

  home.stateVersion = "25.11";
}
