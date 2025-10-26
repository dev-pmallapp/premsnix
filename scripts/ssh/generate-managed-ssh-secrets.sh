#!/usr/bin/env bash
set -euo pipefail

# generate-managed-ssh-secrets.sh
# Helper for creating sops-encrypted SSH host keys and user authorized_keys
# for the premsnix managed-keys module.
#
# Requirements: ssh-keygen, sops, age/pgp key material available to sops.
#
# Usage examples:
#   Create host key:   ./scripts/ssh/generate-managed-ssh-secrets.sh host premsnix
#   Create user keys:  ./scripts/ssh/generate-managed-ssh-secrets.sh user pmallapp ~/.ssh/id_ed25519.pub
#   Create known_hosts: ./scripts/ssh/generate-managed-ssh-secrets.sh known-hosts scan host1 host2
#
# Files produced (encrypted via sops):
#   secrets/hosts/<host>/ssh_host_ed25519_key
#   secrets/users/<user>/authorized_keys
#   secrets/known_hosts
#
# NOTE: This script does NOT overwrite existing encrypted secrets unless --force is given.

force=false
scan_cmd="ssh-keyscan -T 5 -t ed25519"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <host|user|known-hosts> ..." >&2
    exit 1
fi

case "$1" in
--force)
    force=true
    shift
    ;;
esac

action=${1:-}
shift || true

root_dir=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
secrets_dir="$root_dir/secrets"

ensure_parent() {
    mkdir -p "$1"
}

ensure_not_exists() {
    local path=$1
    if [[ -e $path && $force == false ]]; then
        echo "[skip] $path exists (use --force to overwrite)" >&2
        return 1
    fi
    return 0
}

encrypt_file_inplace() {
    local path=$1
    # If file already contains sops metadata, leave it.
    if grep -q 'sops:' "$path" 2>/dev/null; then
        echo "[info] $path already appears encrypted"
        return 0
    fi
    sops --encrypt --in-place "$path"
}

case "$action" in
host)
    host=${1:?"host name required"}
    shift || true
    target_dir="$secrets_dir/hosts/$host"
    ensure_parent "$target_dir"
    host_key="$target_dir/ssh_host_ed25519_key"
    if ensure_not_exists "$host_key"; then
        tmpkey=$(mktemp)
        ssh-keygen -t ed25519 -N '' -f "$tmpkey" >/dev/null
        mv "$tmpkey" "$host_key"
        rm -f "$tmpkey.pub" # public part not needed; can derive if required
        chmod 600 "$host_key"
        encrypt_file_inplace "$host_key"
        echo "[ok] Encrypted host key at $host_key"
    fi
    ;;
user)
    user=${1:?"user name required"}
    pub=${2:-}
    target_dir="$secrets_dir/users/$user"
    ensure_parent "$target_dir"
    auth_file="$target_dir/authorized_keys"
    if ensure_not_exists "$auth_file"; then
        if [[ -n $pub ]]; then
            if [[ -f $pub ]]; then
                cp "$pub" "$auth_file"
            else
                echo "$pub" >"$auth_file"
            fi
        else
            # Try default public key
            if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
                cp "$HOME/.ssh/id_ed25519.pub" "$auth_file"
            else
                echo "ERROR: No public key provided and none at ~/.ssh/id_ed25519.pub" >&2
                exit 2
            fi
        fi
        chmod 644 "$auth_file"
        encrypt_file_inplace "$auth_file"
        echo "[ok] Encrypted authorized_keys at $auth_file"
    fi
    ;;
known-hosts)
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 known-hosts <host> [host2 ...]" >&2
        exit 1
    fi
    out_file="$secrets_dir/known_hosts"
    if ensure_not_exists "$out_file"; then
        : >"$out_file"
        for h in "$@"; do
            echo "[scan] $h" >&2
            $scan_cmd "$h" >>"$out_file" || echo "# scan failed: $h" >>"$out_file"
        done
        encrypt_file_inplace "$out_file"
        echo "[ok] Encrypted known_hosts at $out_file"
    fi
    ;;
*)
    echo "Unknown action: $action (expected host|user|known-hosts)" >&2
    exit 1
    ;;
esac
