{
  config,
  lib,

  ...
}:
let

  cfg = config.premsnix.suites.development;
in
{
  options.premsnix.suites.development = {
    enable = lib.mkEnableOption "common development configuration";
    aiEnable = lib.mkEnableOption "ai development configuration";
    sqlEnable = lib.mkEnableOption "sql development configuration";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      12345
      3000
      3001
      8080
      8081
    ];

    premsnix = {
      user = {
        extraGroups = [ "git" ] ++ lib.optionals cfg.sqlEnable [ "mysql" ];
      };

      services = {
        # FIXME: broken nixpkgs
        # ollama.enable = lib.mkDefault cfg.aiEnable;
        ollama-ui.enable = lib.mkDefault cfg.aiEnable;
        # NOTE: 13 GB closure size!!
        # open-webui.enable = lib.mkDefault cfg.aiEnable;
      };

      # Container/virtualisation selection is now handled by the virtualisation suite.
    };
  };
}
