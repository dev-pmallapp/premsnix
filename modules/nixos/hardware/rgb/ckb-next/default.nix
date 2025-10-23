{
  config,
  lib,

  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.premunix) mkOpt;

  cfg = config.premunix.hardware.rgb.ckb-next;
in
{
  options.premunix.hardware.rgb.ckb-next = with types; {
    enable = lib.mkEnableOption "support for rgb controls";
    ckbNextConfig = mkOpt (nullOr path) null "The ckb-next.conf file to create.";
  };

  config = mkIf cfg.enable {
    hardware.ckb-next.enable = true;

    premunix.home.configFile =
      { }
      // lib.optionalAttrs (cfg.ckbNextConfig != null) {
        "ckb-next/ckb-next.cfg".source = cfg.ckbNextConfig;
      };
  };
}
