{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.premsnix.programs.terminal.editors.micro;
in
{
  options.premsnix.programs.terminal.editors.micro = {
    enable = lib.mkEnableOption "micro";
    default = lib.mkEnableOption "setting micro as the session EDITOR";
  };

  config = mkIf cfg.enable {
    programs = {
      micro = {
        enable = true;

        settings = {
          colorscheme = "catppuccin-macchiato";
        };
      };

      bash.shellAliases.vimdiff = mkIf cfg.default "micro -d";
      fish.shellAliases.vimdiff = mkIf cfg.default "micro -d";
      zsh.shellAliases.vimdiff = mkIf cfg.default "micro -d";
    };

    home.sessionVariables = {
      EDITOR = mkIf cfg.default "micro";
    };

    xdg.configFile."micro/colorschemes" = {
      source = lib.cleanSourceWith {
        filter =
          name: _type:
          let
            baseName = baseNameOf (toString name);
          in
          lib.hasSuffix ".micro" baseName;
        src = lib.cleanSource ./.;
      };

      recursive = true;
    };
  };
}
