{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.programs.graphical.apps._1password;
in
{
  options.premsnix.programs.graphical.apps._1password = {
    enable = lib.mkEnableOption "1password";
    enableSshSocket = lib.mkEnableOption "ssh-agent socket";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password = enabled;
      _1password-gui = {
        enable = true;
        package = pkgs._1password-gui;

        polkitPolicyOwners = [ config.premsnix.user.name ];
      };

      ssh.extraConfig = lib.optionalString cfg.enableSshSocket ''
        Host *
          AddKeysToAgent yes
          IdentityAgent ~/.1password/agent.sock
      '';
    };
  };
}
