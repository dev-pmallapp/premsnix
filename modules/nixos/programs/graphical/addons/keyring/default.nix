{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.graphical.addons.keyring;
in
{
  options.premsnix.programs.graphical.addons.keyring = {
    enable = lib.mkEnableOption "the passwords application";
  };

  config = mkIf cfg.enable { programs.seahorse.enable = true; };
}
