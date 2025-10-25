{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.business;
  isWSL = osConfig.premsnix.archetypes.wsl.enable or false;
in
{
  options.premsnix.suites.business = {
    enable = lib.mkEnableOption "business configuration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        calcurse
        dooit
        jrnl
        np
      ]
      ++ lib.optionals (!isWSL) [
        teams-for-linux
      ]
      ++ lib.optionals (stdenv.hostPlatform.isLinux && !isWSL) [
        libreoffice
        p3x-onenote
      ];

    premsnix = {
      programs = {
        graphical = {
          apps = {
            thunderbird.enable = lib.mkDefault (!isWSL); # No GUI email client in WSL
          };
        };
        terminal = {
          tools = {
            _1password-cli = lib.mkDefault enabled;
          };
        };
      };
      services = {
        # FIXME: requires approval
        davmail.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
        syncthing.enable = lib.mkDefault (!isWSL);
      };
    };
  };
}
