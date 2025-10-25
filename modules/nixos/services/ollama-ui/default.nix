{
  config,
  lib,

  ...
}:
let

  cfg = config.premsnix.services.ollama-ui;
in
{
  options.premsnix.services.ollama-ui = {
    enable = lib.mkEnableOption "ollama ui";
  };

  config = lib.mkIf cfg.enable {
    services.nextjs-ollama-llm-ui = {
      enable = true;
      port = 3001;
    };
  };
}
