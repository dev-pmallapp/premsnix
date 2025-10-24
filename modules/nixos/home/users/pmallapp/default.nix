{
  config,
  lib,
  pkgs,
  ...
}:
# pmallapp user-specific home-manager extensions.
let
  inherit (lib) mkIf;
in
{
  config = mkIf (config.premsnix.user.name == "pmallapp") {
    # Example: add extra CLI networking helpers for the user.
    premsnix.home.extraOptions = {
      home.packages = with pkgs; [
        httpie
        websocat
      ];
    };
  };
}
