#!/usr/bin/env bash
set -euo pipefail
# Lightweight pre-push gate: format + flake check (no builds) unless skipped.
# Install as git hook:
#   mkdir -p .git/hooks
#   ln -sf ../../scripts/pre-push-check.sh .git/hooks/pre-push
# Or set core.hooksPath and copy into that directory.

if [[ ${SKIP_PRE_PUSH:-} == 1 ]]; then
    echo "[pre-push] Skipped via SKIP_PRE_PUSH=1"
    exit 0
fi

echo "[pre-push] nix fmt"
if ! nix fmt; then
    echo "[pre-push] Formatting failed" >&2
    exit 1
fi

# If formatting produced changes, abort so developer recommits
if ! git diff --quiet; then
    echo "[pre-push] Formatting changed files. Please restage & recommit." >&2
    git --no-pager diff --name-only
    exit 1
fi

echo "[pre-push] nix flake check (no build derivations explicitly built here)"
if ! nix flake check --print-build-logs; then
    echo "[pre-push] flake check failed" >&2
    exit 1
fi

echo "[pre-push] OK"
