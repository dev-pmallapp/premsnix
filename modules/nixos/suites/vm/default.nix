{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.vm;
in
{
  options.premsnix.suites.vm = {
    enable = lib.mkEnableOption "common vm configuration";
  };

  config = mkIf cfg.enable {
    premsnix = {
      services = {
        spice-vdagentd = lib.mkDefault enabled;
        spice-webdav = lib.mkDefault enabled;
      };
    };
  };
}
