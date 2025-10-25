{
  config,
  lib,

  ...
}:
let

  cfg = config.premsnix.services.ssh-agent;
in
{
  options.premsnix.services.ssh-agent = {
    enable = lib.mkEnableOption "ssh-agent service";
  };

  config = lib.mkIf cfg.enable {
    services.ssh-agent = {
      enable = true;
    };
  };
}
