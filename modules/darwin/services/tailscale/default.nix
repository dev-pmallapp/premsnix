{
  config,
  lib,

  pkgs,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.premunix) mkOpt;

  cfg = config.premunix.services.tailscale;
in
{
  options.premunix.services.tailscale = {
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
