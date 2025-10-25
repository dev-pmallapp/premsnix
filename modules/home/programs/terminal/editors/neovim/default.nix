{
  config,
  inputs,
  lib,

  osConfig ? { },
  pkgs,
  system,
  ...
}:
let
  inherit (lib.premsnix) mkBoolOpt;
  inherit (lib) mkOption types;

  cfg = config.premsnix.programs.terminal.editors.neovim;

  # Simplified: removed external branded Neovim dependency; rely on a minimal built-in configuration layer.
  baseConfiguration = import (inputs.nixvim or inputs.self.inputs.nixvim) {
    inherit pkgs system;
    modules = [ ];
  };
  extendedConfiguration = baseConfiguration.extendModules {
    modules = [
      {
        config = {
          # NOTE: Conflicting package definitions, use the package from this flake.
          dependencies.yazi.enable = false;
          # FIXME: insane memory usage
          # lsp.servers.nixd.settings.settings.nixd =
          #   let
          #     flake = ''(builtins.getFlake "${inputs.self}")'';
          #   in
          #   {
          #     options = rec {
          #       nix-darwin.expr = ''${flake}.darwinConfigurations.mac.options'';
          #       nixos.expr = ''${flake}.nixosConfigurations.premsnix.options'';
          #       home-manager.expr = ''${nixos.expr}.home-manager.users.type.getSubOptions [ ]'';
          #     };
          #   };
        };
      }
      (lib.mkIf (osConfig.premsnix.archetypes.wsl.enable or false) {
        # FIXME: upstream dependency has LONG build time and transient failures
        # Usually crashes WSL
        lsp.servers.roslyn_ls = {
          enable = lib.mkForce false;
        };

        plugins = {
          yanky = {
            enable = lib.mkForce false;
            settings.ring.permanent_wrapper.__raw = ''require("yanky.wrappers").remove_carriage_return'';
          };
        };

        extraConfigLuaPost = ''
          in_wsl = os.getenv('WSL_DISTRO_NAME') ~= nil

          if in_wsl then
              vim.g.clipboard = {
                  name = 'wsl clipboard',
                  copy =  { ["+"] = { "clip.exe" },   ["*"] = { "clip.exe" } },
                  paste = { ["+"] = { "win32yank.exe -o --lf" }, ["*"] = { "win32yank.exe -o --lf" } },
                  cache_enabled = true
              }
          end
        '';
      })
    ]
    ++ cfg.extraModules;
  };
  neovimPackage = extendedConfiguration.config.build.package;
in
{
  options.premsnix.programs.terminal.editors.neovim = {
    enable = lib.mkEnableOption "neovim";
    default = mkBoolOpt true "Whether to set Neovim as the session EDITOR";
    extraModules = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "Additional nixvim modules to extend the base neovim configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = {
        EDITOR = lib.mkIf cfg.default "nvim";
        MANPAGER = "nvim -c 'set ft=man bt=nowrite noswapfile nobk shada=\\\"NONE\\\" ro noma' +Man! -o -";
      };
      packages = [
        neovimPackage
        pkgs.nvrh
      ];
    };

    sops.secrets = lib.mkIf (osConfig.premsnix.security.sops.enable or false) {
      wakatime = {
        sopsFile = lib.getFile "secrets/pmallapp/default.yaml";
        path = "${config.home.homeDirectory}/.wakatime.cfg";
      };
    };
  };
}
