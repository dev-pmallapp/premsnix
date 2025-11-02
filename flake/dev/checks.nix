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
            enable = false; # disabled to avoid in-place edits during commit
            settings.edit = false;
          };
          eslint = {
            enable = true;
            package = pkgs.eslint_d;
          };
          luacheck.enable = true;
          # Temporarily disable ensure-sops (was failing on raw SSH key files); will re-enable after refining hook upstream.
          pre-commit-hook-ensure-sops.enable = false;
          # Disable statix as a pre-commit hook (still runs via flake check / treefmt programs)
          statix.enable = false;
          # Leave treefmt disabled for pre-commit (handled as pre-push hook via .pre-commit-config.yaml stages)
          treefmt.enable = false;
          # Optionally disable statix if it's blocking commits; leave enabled for now
          # statix.enable = false;
          typos = {
            enable = true;
            excludes = [
              "generated/*"
              ".*\\.svg"
              # Exclude encrypted secrets to avoid false positives on ciphertext
              "secrets/.*\\.yaml"
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
