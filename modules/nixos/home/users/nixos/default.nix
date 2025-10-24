{ config, lib, ... }:
# Root (nixos) user home-manager stub configuration.
# Extend as needed for root-specific dotfiles.
let
  inherit (lib) mkIf;
in
{
  config = mkIf (config.premsnix.user.name != "nixos") {
    # If primary user is not nixos, we still can define a minimal HM profile for root.
    home-manager.users.nixos = {
      home.stateVersion = config.system.stateVersion;
    };
  };
}
