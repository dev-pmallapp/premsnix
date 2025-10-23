{
  config,
  lib,

  ...
}:
let

  cfg = config.premunix.services.open-webui;
in
{
  options.premunix.services.open-webui = {
    enable = lib.mkEnableOption "ollama ui";
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      openFirewall = true;
    };
  };
}
