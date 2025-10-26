{ lib, pkgs, ... }:
let
  inherit (lib) mkAfter mkForce;
  expireScript = pkgs.writeShellScript "expire-initial-passwords" ''
    set -eu
    stampDir=/var/lib/premsnix/password-expiry
    mkdir -p "$stampDir"
    for u in nixos pmallapp; do
      if id "$u" >/dev/null 2>&1; then
        if [ ! -e "$stampDir/$u" ]; then
          # Force password change on next login
          ${pkgs.shadow}/bin/chage -d 0 "$u" || true
          touch "$stampDir/$u"
        fi
      fi
    done
  '';
in
{
  users = {
    mutableUsers = true;
    users = {
      nixos = {
        isNormalUser = true;
        createHome = true;
        description = "Bootstrap user (will be rotated)";
        initialPassword = mkForce "nixos";
        extraGroups = mkForce [
          "wheel"
          "networkmanager"
        ];
        group = mkForce "nixos";
      };
      pmallapp = {
        isNormalUser = true;
        createHome = true;
        description = "Primary user";
        # Keep overriding initial password for first rollout
        initialPassword = mkForce "prem123";
        # Merge-in networkmanager; base module supplies rest (list type concatenates)
        extraGroups = [ "networkmanager" ];
        group = mkForce "pmallapp";
      };
    };
    groups = {
      nixos = { };
      pmallapp = { };
    };
  };

  # Activation hook to expire passwords on first boot / after rebuild introducing them
  system.activationScripts.expireInitialPasswords = mkAfter ''
    ${expireScript}
  '';
}
