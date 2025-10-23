{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premunix) enabled;

  cfg = config.premunix.suites.vm;
in
{
  options.premunix.suites.vm = {
    enable = lib.mkEnableOption "common vm configuration";
  };

  config = mkIf cfg.enable {
    premunix = {
      services = {
        spice-vdagentd = lib.mkDefault enabled;
        spice-webdav = lib.mkDefault enabled;
      };
    };
  };
}
