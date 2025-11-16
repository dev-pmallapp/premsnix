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
          deadnix.enable = false; # disabled to avoid in-place edits during commit
        };
      };

      checks = {
        ssh-strict =
          let
            nixosHosts = (inputs.self.nixosConfigurations or {});
            darwinHosts = (inputs.self.darwinConfigurations or {});
            # Combine both into a unified check
            allHosts = builtins.attrNames nixosHosts ++ builtins.attrNames darwinHosts;
            # Legacy / deprecated or non-target hosts to skip
            skipHosts = [ ];
            failures =
              lib.concatMap (
                h:
                if lib.elem h skipHosts then [ ] else
                let 
                  cfg = 
                    if builtins.hasAttr h nixosHosts 
                    then (nixosHosts.${h}.config.premsnix.security.openssh.managedKeys or {})
                    else (darwinHosts.${h}.config.premsnix.security.openssh.managedKeys or {});
                in
                let msgs = [ ]
                  ++ (if (cfg ? strict && cfg.strict == true) then [ ] else [ "${h}: strict != true" ])
                  ++ (if (cfg ? warnMissing && cfg.warnMissing == true) then [ "${h}: warnMissing should be removed under strict" ] else [ ])
                  ++ (if !(builtins.pathExists (inputs.self + "/secrets/hosts/" + h + "/ssh_host_ed25519_key")) then [ "${h}: missing host key secret secrets/hosts/${h}/ssh_host_ed25519_key" ] else [ ])
                ; in msgs
              ) allHosts
              ++ (if !(builtins.pathExists (inputs.self + "/secrets/users/pmallapp/authorized_keys")) then [ "global: missing user authorized_keys secret" ] else [ ])
              ++ (if !(builtins.pathExists (inputs.self + "/secrets/known_hosts")) then [ "global: missing known_hosts secret" ] else [ ]);
            failText = lib.concatStringsSep "\n - " failures;
          in pkgs.runCommand "ssh-strict-check" { } ''
            if [ ${toString (builtins.length failures)} -gt 0 ]; then
              echo 'SSH strict mode check failures:' >&2
              echo -e ' - ${failText}' >&2
              exit 1
            fi
            echo 'All systems have strict SSH managed keys enforced and required secrets present.' >&2
            touch $out
          '';
        ssh-strict-json =
          let
            nixosHosts = (inputs.self.nixosConfigurations or {});
            darwinHosts = (inputs.self.darwinConfigurations or {});
            allHosts = builtins.attrNames nixosHosts ++ builtins.attrNames darwinHosts;
            skipHosts = [ ];
            perHost = lib.genAttrs allHosts (
              h:
              let 
                cfg = 
                  if builtins.hasAttr h nixosHosts 
                  then (nixosHosts.${h}.config.premsnix.security.openssh.managedKeys or {})
                  else (darwinHosts.${h}.config.premsnix.security.openssh.managedKeys or {});
              in
              let hasKey = builtins.pathExists (inputs.self + "/secrets/hosts/" + h + "/ssh_host_ed25519_key"); in
              {
                strict = cfg ? strict && cfg.strict == true;
                warnMissing = cfg ? warnMissing && cfg.warnMissing == true;
                hostKeyPresent = hasKey;
                skipped = lib.elem h skipHosts;
                platform = if builtins.hasAttr h nixosHosts then "nixos" else "darwin";
                status = if lib.elem h skipHosts then "skipped" else if (cfg ? strict && cfg.strict == true && hasKey) then "ok" else "fail";
              }
            );
            global = {
              authorizedKeysPresent = builtins.pathExists (inputs.self + "/secrets/users/pmallapp/authorized_keys");
              knownHostsPresent = builtins.pathExists (inputs.self + "/secrets/known_hosts");
            };
            failures = builtins.length (lib.filter (h: let v = perHost.${h}; in v.status != "ok") allHosts)
              + (if global.authorizedKeysPresent then 0 else 1)
              + (if global.knownHostsPresent then 0 else 1);
            json = builtins.toJSON { inherit perHost global failures; totalHosts = builtins.length allHosts; };
          in pkgs.runCommand "ssh-strict-json" { } ''
            cat > $out <<'JSON'
            ${json}
            JSON
          '';
      };
    };
}
