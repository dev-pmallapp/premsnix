#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-}"         # optional: override with env or --host
MAC_HOST="${MAC_HOST:-}" # optional macOS host
USER_NAME="${USER_NAME:-${USER:-}}"

usage() {
    cat <<EOF
Usage: dev-check.sh [--host HOST] [--mac-host MAC] [--home USER@HOST] [--no-build] [--skip-flake] [--fix]

Runs the standard pre-commit manual checklist:
  1. nix fmt
  2. nix flake check
  3. Optional system builds
  4. Optional home build
  5. Reports status & exits non-zero on failure

Options:
  --host HOST         NixOS host to build (nixosConfigurations.HOST)
  --mac-host HOST     Darwin host to build (darwinConfigurations.HOST)
  --home USER@HOST    Home config to build (homeConfigurations."USER@HOST")
  --no-build          Skip all build steps
  --skip-flake        Skip nix flake check (not recommended)
  --fix               Attempt auto-fix (deadnix --edit, statix fix, then nix fmt)
  -h, --help          Show this help

Environment overrides:
  HOST, MAC_HOST, HOME_TARGET

Examples:
  ./scripts/dev-check.sh --host premsnix
  HOST=premsnix ./scripts/dev-check.sh
EOF
}

NO_BUILD=0
DO_FLAKE=1
DO_FIX=0
HOME_TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
    --host)
        HOST="$2"
        shift 2
        ;;
    --mac-host)
        MAC_HOST="$2"
        shift 2
        ;;
    --home)
        HOME_TARGET="$2"
        shift 2
        ;;
    --no-build)
        NO_BUILD=1
        shift
        ;;
    --skip-flake)
        DO_FLAKE=0
        shift
        ;;
    --fix)
        DO_FIX=1
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "Unknown arg: $1" >&2
        usage
        exit 1
        ;;
    esac
done

section() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
fail() {
    printf '\n\033[1;31mFAIL:\033[0m %s\n' "$*" >&2
    exit 1
}

MODIFIED_BEFORE=$(git status --porcelain | wc -l)

if [[ $DO_FIX -eq 1 ]]; then
    section "0. Auto-fix (deadnix/statix)"
    if command -v deadnix >/dev/null 2>&1; then
        deadnix --edit . || true
    fi
    if command -v statix >/dev/null 2>&1; then
        statix fix . || true
    fi
fi

section "1. Formatting (nix fmt)"
if ! nix fmt; then fail "nix fmt failed"; fi

if [[ $(git status --porcelain | wc -l) -ne $MODIFIED_BEFORE ]]; then
    section "Formatting applied. Restaging modified files (if already staged)."
fi

section "2. Flake Check"
if [[ $DO_FLAKE -eq 1 ]]; then
    if ! nix flake check; then fail "flake check failed"; fi
else
    echo "(Skipped)"
fi

if [[ $NO_BUILD -eq 0 ]]; then
    if [[ -n $HOST ]]; then
        section "3a. Building NixOS host: $HOST"
        if ! nix build ".#nixosConfigurations.${HOST}.config.system.build.toplevel"; then fail "NixOS host build failed"; fi
    fi
    if [[ -n $MAC_HOST ]]; then
        section "3b. Building Darwin host: $MAC_HOST"
        if ! nix build ".#darwinConfigurations.${MAC_HOST}.system"; then fail "Darwin host build failed"; fi
    fi
    if [[ -n $HOME_TARGET ]]; then
        section "3c. Building Home config: $HOME_TARGET"
        if ! nix build ".#homeConfigurations.\"${HOME_TARGET}\".activationPackage"; then fail "Home config build failed"; fi
    fi
fi

section "4. Git Diff (staged)"
git diff --cached --name-only || true

section "5. Summary"
echo "All checks passed."
if git diff --quiet; then
    echo "Working tree clean (post-format)."
else
    echo "Unstaged changes remain; review and stage as needed."
fi

exit 0
