{
  config,
  lib,

  ...
}:
let

  cfg = config.premsnix.services.open-webui;
in
{
  options.premsnix.services.open-webui = {
    enable = lib.mkEnableOption "ollama ui";
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      openFirewall = true;
    };
  };
}
