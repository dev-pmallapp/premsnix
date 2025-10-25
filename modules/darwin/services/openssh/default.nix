{
  config,
  lib,

  ...
}:
let
  inherit (lib)
    types
    mkIf
    ;
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.services.openssh;
in
{
  options.premsnix.services.openssh = with types; {
    enable = lib.mkEnableOption "OpenSSH support";
    authorizedKeys = mkOpt (listOf str) [ ] "The public keys to apply.";
    extraConfig = mkOpt str "" "Extra configuration to apply.";
    port = mkOpt port 2222 "The port to listen on (in addition to 22).";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
    };
  };
}
