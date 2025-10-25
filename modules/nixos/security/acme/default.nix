{
  config,
  lib,
  virtual,

  ...
}:
let
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.security.acme;
in
{
  options.premsnix.security.acme = {
    enable = lib.mkEnableOption "default ACME configuration";
    email = mkOpt lib.types.str config.premsnix.user.email "The email to use.";
    staging = mkOpt lib.types.bool virtual "Whether to use the staging server or not.";
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;

      defaults = {
        inherit (cfg) email;

        group = lib.mkIf config.services.nginx.enable "nginx";
        # Reload nginx when certs change.
        reloadServices = lib.optional config.services.nginx.enable "nginx.service";
        server = lib.mkIf cfg.staging "https://acme-staging-v02.api.letsencrypt.org/directory";
      };
    };
  };
}
