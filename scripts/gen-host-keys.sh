#!/usr/bin/env bash
set -euo pipefail

hosts=(nixos nuc nuc-v09 nuc-v11 premsnix rpi4 thinkpad-p16s)

# Ensure sops available; if not, re-exec inside nix shell providing sops
if ! command -v sops >/dev/null 2>&1; then
  echo "[gen-host-keys] sops not in PATH; entering nix shell providing sops..." >&2
  exec nix shell nixpkgs#sops -c "$0" "$@"
fi

for h in "${hosts[@]}"; do
  keyfile="/tmp/${h}_hostkey"
  target="secrets/hosts/${h}/ssh_host_ed25519_key"
  mkdir -p "secrets/hosts/${h}"
  # Skip if already looks encrypted or is an OpenSSH private key
  if [[ -f "$target" ]]; then
    firstLine=$(head -1 "$target" || true)
    if [[ $firstLine =~ ^(ENC\[AES256_GCM,data:|-----BEGIN OPENSSH PRIVATE KEY-----) ]]; then
      echo "[gen-host-keys] Skipping $h (existing key present)" >&2
      continue
    fi
  fi
  echo "[gen-host-keys] Generating ed25519 key for $h" >&2
  ssh-keygen -q -t ed25519 -N '' -f "$keyfile"
  mv "$keyfile" "$target"
  # Encrypt in place with sops
  sops --encrypt --in-place "$target"
  # Remove public key (can recreate from private when needed)
  rm -f "${keyfile}.pub"
  echo "[gen-host-keys] Encrypted key stored at $target" >&2
done

echo "[gen-host-keys] Done. Run: git add secrets/hosts/*/ssh_host_ed25519_key && git commit -m 'Add encrypted host keys'" >&2
