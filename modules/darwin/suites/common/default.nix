{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.common;
in
{
  imports = [ (lib.getFile "modules/common/suites/common/default.nix") ];

  config = mkIf cfg.enable {
    programs.zsh.enable = mkDefault true;

    homebrew = {
      brews = [
        "bashdb"
      ];
    };

    environment = {
      systemPackages =
        with pkgs;
        [
          duti
          gawk
          gnugrep
          gnupg
          gnused
          gnutls
          terminal-notifier
          trash-cli
          wtfutil
        ]
        ++ lib.optionals config.premsnix.tools.homebrew.masEnable [
          mas
        ];
    };

    premsnix = {
      home.extraOptions = {
        home.shellAliases = {
          # Prevent shell log command from overriding macos log
          log = ''command log'';
        };
      };

      nix = mkDefault enabled;

      programs.terminal.tools = {
        atuin = mkDefault enabled;
        nh = mkDefault enabled;
        ssh = mkDefault enabled;
      };

      tools = {
        homebrew = mkDefault enabled;
      };

      services = {
        openssh = mkDefault enabled;
      };

      system = {
        fonts = mkDefault enabled;
        input = mkDefault enabled;
        interface = mkDefault enabled;
        logging = mkDefault enabled;
        networking = mkDefault enabled;
      };
    };

    system.activationScripts.postActivation.text = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 ''
      echo "Installing Rosetta..."
      softwareupdate --install-rosetta --agree-to-license
    '';
  };
}
