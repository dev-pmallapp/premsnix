{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.premsnix) enabled;

  cfg = config.premsnix.suites.common;
in
{
  imports = [ (lib.getFile "modules/common/suites/common/default.nix") ];

  config = mkIf cfg.enable {
    environment = {
      defaultPackages = lib.mkForce [ ];

      systemPackages =
        let
          base = with pkgs; [
            dnsutils
            isd
            lazyjournal
            lshw
            pciutils
            rsync
            util-linux
            wget
          ];
        in
        base ++ lib.optionals (!pkgs.stdenv.hostPlatform.isAarch64) [ pkgs.usbimager ];
    };

    premsnix = {
      hardware = {
        power = mkDefault enabled;
        fans = mkDefault enabled;
      };

      nix = mkDefault enabled;

      programs = {
        terminal = {
          tools = {
            bandwhich = mkDefault enabled;
            nix-ld = mkDefault enabled;
            ssh = mkDefault enabled;
          };
        };
      };

      security = {
        # auditd = mkDefault enabled;
        clamav = mkDefault enabled;
        gpg = mkDefault enabled;
        pam = mkDefault enabled;
        usbguard = mkDefault enabled;
      };

      services = {
        ddccontrol = mkDefault enabled;
        earlyoom = mkDefault enabled;
        lact = mkDefault enabled;
        logind = mkDefault enabled;
        logrotate = mkDefault enabled;
        oomd = mkDefault enabled;
        openssh = mkDefault enabled;
        printing = mkDefault enabled;
        # resources-limiter = mkDefault enabled;
      };

      system = {
        fonts = mkDefault enabled;
        hostname = mkDefault enabled;
        locale = mkDefault enabled;
        time = mkDefault enabled;
      };
    };

    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      histFile = "$XDG_CACHE_HOME/zsh.history";
    };

    zramSwap.enable = true;
  };
}
