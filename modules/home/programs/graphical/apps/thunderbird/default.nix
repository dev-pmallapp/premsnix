{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.premsnix) mkOpt;

  cfg = config.premsnix.programs.graphical.apps.thunderbird;
in
{
  options.premsnix.programs.graphical.apps.thunderbird = {
    enable = lib.mkEnableOption "thunderbird";
    accountsOrder = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Custom ordering of accounts.";
    };
    extraCalendarAccounts = lib.mkOption {
      type =
        let
          accountType = lib.types.submodule {
            options = {
              url = mkOpt lib.types.str null "Calendar url";
              type = mkOpt (lib.types.enum [
                "caldav"
                "http"
              ]) null "Calendar flavor";
              color = mkOpt lib.types.str null "color";
            };
          };
        in
        lib.types.attrsOf accountType;
      default = {
        "Milwaukee Bucks" = {
          url = "https://apidata.googleusercontent.com/caldav/v2/jeb1pn12iqgftnq21ae2qjljetlr43cv%40import.calendar.google.com/events/";
          type = "caldav";
          color = "#05491C";
        };
        "US Holidays" = {
          url = "https://apidata.googleusercontent.com/caldav/v2/cln2stbjc4hmgrrcd5i62ua0ctp6utbg5pr2sor1dhimsp31e8n6errfctm6abj3dtmg%40virtual/events/";
          type = "caldav";
          color = "#92cfe1";
        };
        "Green Bay Packers" = {
          url = "https://sports.yahoo.com/nfl/teams/gnb/ical.ics";
          type = "http";
          color = "#F9BC12";
        };
      };
      description = "Extra calendar accounts to configure.";
    };
    extraEmailAccounts = lib.mkOption {
      type =
        let
          accountType = lib.types.submodule {
            options = {
              enable = mkOpt lib.types.bool true "Enable this account";
              address = mkOpt lib.types.str null "Email address";
              flavor = mkOpt (lib.types.enum [
                "plain"
                "gmail.com"
                "runbox.com"
                "fastmail.com"
                "yandex.com"
                "outlook.office365.com"
                "davmail"
              ]) null "Email flavor";
            };
          };
        in
        lib.types.attrsOf accountType;
      default = { };
      description = "Extra email accounts to configure.";
    };
  };

  config = mkIf cfg.enable {

    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (
      with pkgs;
      [
        birdtray
      ]
    );

    accounts = {
      calendar.accounts =
        let
          mkCalendarConfig =
            {
              url,
              type,
              color ? "#9a9cff",
            }:
            {
              remote = {
                inherit type url;
                userName = config.premsnix.user.email;
              };
              local = {
                inherit color;
              };
              thunderbird = {
                enable = true;
                profiles = [
                  config.premsnix.user.name
                ];
                inherit color;
              };
            };
        in
        {
          "${config.premsnix.user.email}" = {
            remote = {
              type = "caldav";
              url = "https://apidata.googleusercontent.com/caldav/v2/pmallapp12%40gmail.com/events/";
              userName = config.premsnix.user.email;
            };
            primary = true;
            thunderbird = {
              enable = true;
              profiles = [
                config.premsnix.user.name
              ];
              color = "#16a765";
            };
          };
        }
        // lib.mapAttrs (_name: mkCalendarConfig) cfg.extraCalendarAccounts;
      email.accounts =
        let
          mkEmailConfig =
            {
              address,
              primary ? false,
              enable ? true,
              flavor,
            }:
            let
              finalEnable =
                if flavor == "davmail" && !config.premsnix.services.davmail.enable then
                  lib.warn "Davmail account '${address}' is disabled because davmail service is not enabled." false
                else
                  enable;
            in
            {
              enable = finalEnable;
              inherit
                address
                flavor
                primary
                ;
              realName = config.premsnix.user.fullName;
              userName = lib.mkIf (flavor == "davmail") address;
              thunderbird = {
                enable = finalEnable;
                profiles = [
                  config.premsnix.user.name
                ];
                settings = _id: {
                };
              };
            };
        in
        {
          "${config.premsnix.user.email}" = mkEmailConfig {
            address = config.premsnix.user.email;
            primary = true;
            flavor = "gmail.com";
          };
        }
        // lib.mapAttrs (_name: mkEmailConfig) cfg.extraEmailAccounts;
    };

    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-latest;

      profiles.${config.premsnix.user.name} = {
        isDefault = true;

        inherit (cfg) accountsOrder;

        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "layers.acceleration.force-enabled" = true;
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "gfx.direct2d.disabled" = false;
          "svg.context-properties.content.enabled" = true;
          "browser.display.use_system_colors" = true;
          "browser.theme.dark-toolbar-theme" = true;
          "mailnews.default_sort_type" = 18;
          "mailnews.default_sort_order" = 2;
          "mail.tabs.drawInTitlebar" = false;
        };

        userChrome = # css
          ''
            #spacesToolbar,
            #agenda-container,
            #agenda,
            #agenda-toolbar,
            #mini-day-box
            {
              background-color: #24273a !important;
            }
          '';

        # TODO: Bundle extensions
      };
    };
  };
}
