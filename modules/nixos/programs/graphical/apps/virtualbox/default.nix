{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.graphical.apps.virtualbox;
in
{
  options.premsnix.programs.graphical.apps.virtualbox = {
    enable = lib.mkEnableOption "Virtualbox";
  };

  config = mkIf cfg.enable {
    premsnix.user.extraGroups = [ "vboxusers" ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}
