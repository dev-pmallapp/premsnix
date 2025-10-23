{ inputs, lib, ... }:
{
  imports = lib.optional (inputs.git-hooks-nix ? flakeModule) inputs.git-hooks-nix.flakeModule;

  perSystem =
    { pkgs, ... }:
    {
      pre-commit = lib.mkIf (inputs.git-hooks-nix ? flakeModule) {
        check.enable = false;

        settings.hooks = {
          # FIXME: broken dependency on darwin
          actionlint.enable = pkgs.stdenv.hostPlatform.isLinux;
          clang-tidy = {
            enable = pkgs.stdenv.hostPlatform.isDarwin;
            excludes = [
              "modules/home/programs/graphical/bars/sketchybar/dynamic-island-sketchybar/helper/.*"
            ];
          };
          deadnix = {
            enable = true;

            settings = {
              edit = true;
            };
          };
          eslint = {
            enable = true;
            package = pkgs.eslint_d;
          };
          luacheck.enable = true;
          pre-commit-hook-ensure-sops.enable = true;
          statix.enable = true;
          treefmt.enable = true;
          typos = {
            enable = true;
            excludes = [
              "generated/*"
              ".*\\.svg"
              "modules/home/programs/graphical/bars/sketchybar/dynamic-island-sketchybar/.*"
              "modules/home/programs/graphical/apps/caprine/custom\\.css"
              "modules/home/programs/terminal/tools/ssh/default\\.nix"
              "modules/home/programs/terminal/tools/git/shell-aliases\\.nix"
              "modules/home/programs/graphical/bars/waybar/modules/(hyprland|sway)-modules\\.nix"
              "modules/home/programs/terminal/media/ncmpcpp/default\\.nix"
              "modules/home/suites/(emulation|development|video)/default\\.nix"
            ];
          };
        };
      };

      checks = {
        # TODO:
        # Custom checks can go here
        # nix-syntax = pkgs.runCommand "check-nix-syntax" { } ''
        #   find ${./../..} -name "*.nix" -exec ${pkgs.nix}/bin/nix-instantiate --parse {} \; > /dev/null
        #   touch $out
        # '';
      };
    };
}
