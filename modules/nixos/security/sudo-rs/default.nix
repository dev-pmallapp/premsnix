{
  config,
  lib,
  pkgs,

  ...
}:
let

  cfg = config.premsnix.security.sudo-rs;
in
{
  options.premsnix.security.sudo-rs = {
    enable = lib.mkEnableOption "replacing sudo with sudo-rs";
  };

  config = lib.mkIf cfg.enable {
    security.sudo-rs = {
      enable = true;
      package = pkgs.sudo-rs;

      wheelNeedsPassword = false;

      # extraRules = [
      #   {
      #     noPass = true;
      #     users = [ config.premsnix.user.name ];
      #   }
      # ];
    };
  };
}
