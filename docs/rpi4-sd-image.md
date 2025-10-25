# Raspberry Pi 4 Headless SD Image

This document describes how to build and flash the slim headless Raspberry Pi 4
image defined in this flake (`systems/aarch64-linux/rpi4`).

## Features

- Minimal service footprint (no desktop, fonts, printers, fwupd, etc.)
- Optional secret‑driven Wi‑Fi provisioning (NetworkManager connection)
- sops-nix integration for host + (opt-in) user SSH keys & known_hosts
- Network tooling pared down via exclusion list

## Prerequisites

- Nix with flakes enabled
- Aarch64 cross or native environment (building on x86_64-linux works; Nix will
  cross build where needed)
- 8GB+ microSD card (faster cards recommended)

## Build

```bash
nix build .#nixosConfigurations.rpi4.config.system.build.sdImage
```

Result appears under:

```
result/sd-image/nixos-sd-image-<date>-rpi4-linux.img.zst
```

## Flash

Replace `/dev/sdX` with your SD card device node (NOT a partition):

```bash
img=$(readlink -f result/sd-image/*.img.zst)
zstd -d "$img" -c | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

## Optional Secrets

If present, the following sops-managed paths are used:

```
secrets/premsnix/rpi4/default.yaml                # defaultSopsFile (general host secrets)
secrets/hosts/rpi4/ssh_host_ed25519_key           # Host SSH key (managed)
secrets/users/pmallapp/authorized_keys            # Authorized keys (enable manageUserAuthorizedKeys after adding)
secrets/known_hosts                               # Global known hosts file
```

### Wi‑Fi Provisioning

Add a NetworkManager connection (`networkmanager/home.nmconnection`) inside the
host sops file referenced by `defaultSopsFile`. It will be installed to:

```
/etc/NetworkManager/system-connections/premsnix-home.nmconnection
```

with restrictive permissions.

## Enabling Managed User Keys

Edit `systems/aarch64-linux/rpi4/default.nix` and set:

```nix
premsnix.security.openssh.managedKeys.manageUserAuthorizedKeys = true;
```

after adding the `secrets/users/pmallapp/authorized_keys` secret.

## Regenerating Host SSH Key Secret

If you want a new host key:

```bash
ssh-keygen -t ed25519 -N '' -f ssh_host_ed25519_key
sops -e ssh_host_ed25519_key > secrets/hosts/rpi4/ssh_host_ed25519_key
rm ssh_host_ed25519_key
```

(Rebuild image or deploy normally after committing.)

## Troubleshooting

- Pure eval failures: Ensure managed user keys are disabled until secret exists.
- No Wi‑Fi on first boot: Confirm the nmconnection secret file path &
  permissions; rebuild image after adding.
- SSH key mismatch: Regenerate host key secret or remove the host from
  known_hosts locally.

## Next Steps

- Automate publishing of sdImage in nightly workflow.
- Add a shrink step or image size trimming if needed.
