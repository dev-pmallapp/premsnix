{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.services.tailscale;
in
{
  options.premsnix.services.tailscale = {
    enable = mkOpt types.bool true "Whether to enable the Nix daemon.";
  };

  config = mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
        package = pkgs.tailscale;
      };
    };
  };
}
