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
      # Keep only truly baseline toggles here; richer features moved into archetypes
      hardware = {
        power = mkDefault enabled;
        fans = mkDefault enabled;
      };

      nix = mkDefault enabled;

      programs.terminal.tools = {
        nix-ld = mkDefault enabled;
        ssh = mkDefault enabled;
      };

      security = {
        pam = mkDefault enabled;
        gpg = mkDefault enabled;
      };

      services = {
        logind = mkDefault enabled;
      };

      system = {
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
