# Managed SSH Keys Migration Plan

Goal: Replace all statically embedded authorized keys and ad-hoc host key
handling with sops-managed secrets while preserving access and maintaining pure
flake evaluation.

## Phases

1. Inventory & Freeze (DONE)
   - Locate all occurrences of hard-coded authorizedKeys (system & home layers).
   - Stop adding new static keys; introduce conditional empty sets when managed
     mode is enabled.

2. Module Hardening (IN PROGRESS)
   - Ensure `modules/nixos/security/openssh/managed-keys.nix` does not break
     pure evaluation when secrets or paths are absent.
   - Defer references to secret material until activation/runtime. (Current:
     still requires refinement; referencing secret paths in `environment.etc`
     may cause future pure eval constraints.)

3. Pilot Rollout
   - Enable `manageHostKey` + `manageKnownHosts` on a single workstation (e.g.
     `thinkpad-p16s`).
   - Keep `manageUserAuthorizedKeys = false` initially; verify host key rotation
     & known_hosts deployment.

4. User Authorized Keys Enablement
   - Add `secrets/users/<user>/authorized_keys` for each target user.
   - Flip `manageUserAuthorizedKeys = true` host-by-host (servers first, then
     workstations, finally headless images).

5. rpi4 Re-Enablement
   - After module adjustments for pure eval, re-enable managed keys on `rpi4`
     (host + known hosts; authorized keys last).

6. Cleanup & Enforcement
   - Remove any legacy static key snippets left behind.
   - CI check (brand-scan style) for forbidden legacy SSH key literals or
     deprecated paths.

## Secret Layout

```
secrets/
  hosts/<hostname>/ssh_host_ed25519_key        # ENC ed25519 host key (sops file; decrypted to /run at activation)
  users/<username>/authorized_keys             # ENC authorized keys blob
  known_hosts                                  # Optional shared known_hosts
  premsnix/<hostname>/default.yaml             # Host specific general secrets (referenced as defaultSopsFile)
```

## Key Generation Examples

```bash
# Host key
ssh-keygen -t ed25519 -N '' -f ssh_host_ed25519_key
sops -e ssh_host_ed25519_key > secrets/hosts/<hostname>/ssh_host_ed25519_key
rm ssh_host_ed25519_key

# User authorized keys (aggregate existing)
cat ~/.ssh/id_ed25519.pub other.pub > authorized_keys
sops -e authorized_keys > secrets/users/<user>/authorized_keys
rm authorized_keys
```

## Rollback Strategy

- Disable module flags (`manageHostKey`, `manageUserAuthorizedKeys`,
  `manageKnownHosts`) to fall back to static definitions (ensure at least one
  static path retained until fully purged).
- Keep previous static arrays in VCS history; do not delete last-known-good keys
  until new secrets validated.

## Pure Evaluation Considerations

- Avoid direct references to `/run` secret paths inside options evaluated during
  `nix flake check`.
- Prefer using service-level configuration that consumes secrets at activation
  (e.g. leveraging `services.openssh.hostKeys` with derivation indirection) if
  current approach reintroduces impurity.
- If necessary, gate `environment.etc` population behind a derivation that reads
  symbolic links only at build time (still pure) or switch to
  `system.activationScripts` to copy secrets post-eval.

## Acceptance Criteria

- All hosts: zero static authorized key literals in repo.
- Flake evaluates purely with all managed flags enabled on any host
  configuration.
- CI brand scan extended to detect stray `ssh-ed25519` literals of legacy keys
  (optional heuristic).
- Documentation (this file + README link) describes enabling, adding new keys,
  and rollback.

## Next Immediate Actions

- Refactor managed-keys module to eliminate environment.etc secret copying
  (replace with activation script or rely on sshd hostKeys list).
- Pilot enable on `thinkpad-p16s` with `manageHostKey` + `manageKnownHosts`.
- Validate `nix flake check` remains pure.
