{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.services.sops;
in
{
  options.premsnix.services.sops = with types; {
    enable = lib.mkEnableOption "sops";
    defaultSopsFile = mkOpt path null "Default sops file.";
    sshKeyPaths = mkOpt (listOf path) [ ] "SSH Key paths to use.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
    ];

    sops = {
      inherit (cfg) defaultSopsFile;
      defaultSopsFormat = "yaml";

      age = {
        generateKey = true;
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ] ++ cfg.sshKeyPaths;
      };

      secrets = {
        nix = {
          sopsFile = lib.getFile "secrets/pmallapp/default.yaml";
          path = "${config.home.homeDirectory}/.config/nix/nix.conf";
        };
      };
    };
  };
}
