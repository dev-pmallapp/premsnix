{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premunix.programs.graphical.apps.virtualbox;
in
{
  options.premunix.programs.graphical.apps.virtualbox = {
    enable = lib.mkEnableOption "Virtualbox";
  };

  config = mkIf cfg.enable {
    premunix.user.extraGroups = [ "vboxusers" ];

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}
