{ lib, pkgs, ... }:
# Derivation that validates all systems have strict managed SSH keys enabled.
# Fails build if any host lacks strict=true or still sets warnMissing.
let
  # Each entry refers to the flake output under systems.<system>.<host>
  systems = [
    "x86_64-linux.premsnix"
    "x86_64-linux.nuc"
    "x86_64-linux.nixos"
    "x86_64-linux.thinkpad-p16s"
    "aarch64-linux.rpi4"
  ];
  checkScript = pkgs.writeShellScript "check-ssh-strict" ''
    set -euo pipefail
    failures=()
    for s in ${lib.concatStringsSep " " systems}; do
      # Translate symbolic list entry to flakes attribute path (systems.<arch>.<host>)
      managed=$(nix eval --raw .#systems.${s}.config.premsnix.security.openssh.managedKeys.strict 2>/dev/null || echo "false")
      warnMissing=$(nix eval --raw .#systems.${s}.config.premsnix.security.openssh.managedKeys.warnMissing 2>/dev/null || echo "false")
      if [ "$managed" != "true" ]; then
        failures+=("${s}: strict != true")
      fi
      if [ "$warnMissing" = "true" ]; then
        failures+=("${s}: warnMissing still true (should be removed/false under strict)")
      fi
    done
    if [ "${#failures[@]}" -gt 0 ]; then
      printf 'SSH strict mode check failures:\n' >&2
      printf ' - %s\n' "${failures[@]}" >&2
      exit 1
    fi
    echo "All systems have strict SSH managed keys enforced." >&2
    touch $out
  '';
 in pkgs.runCommand "ssh-strict-check" { } ''
  ${checkScript}
''
