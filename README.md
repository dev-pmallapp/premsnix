<h3 align="center">
 <img src="https://avatars.githubusercontent.com/u/1778670?v=4" width="100" alt="Logo"/><br/>
 <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
 <img src="https://nixos.org/logo/nixos-logo-only-hires.png" height="20" /> NixOS Config for <a href="https://github.com/pmallapp">Pmallapp</a>
 <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p align="center">
 <a href="https://github.com/pmallapp/premsnix/stargazers"><img src="https://img.shields.io/github/stars/pmallapp/premsnix?colorA=363a4f&colorB=b7bdf8&style=for-the-badge"></a>
 <a href="https://github.com/pmallapp/premsnix/commits"><img src="https://img.shields.io/github/last-commit/pmallapp/premsnix?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
  <a href="https://wiki.nixos.org/wiki/Flakes" target="_blank">
 <img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge">
</a>
 <a href="https://github.com/pmallapp/premsnix/actions/workflows/fmt.yml"><img src="https://img.shields.io/github/actions/workflow/status/pmallapp/premsnix/fmt.yml?branch=main&label=fmt&colorA=363a4f&colorB=8aadf4&style=for-the-badge"></a>
 <a href="https://github.com/pmallapp/premsnix/actions/workflows/lint.yml"><img src="https://img.shields.io/github/actions/workflow/status/pmallapp/premsnix/lint.yml?branch=main&label=lint&colorA=363a4f&colorB=a6da95&style=for-the-badge"></a>
</p>

Welcome to premsnix, a personal Nix configuration repository. This repository
contains my NixOS and Nixpkgs configurations, along with various tools and
customizations to enhance the Nix experience.

> Tip: When making Nix changes (formatting, checks, secrets management), enter the dev shell first:
> `nix develop .#default` (or use `direnv` to auto-load). This ensures tools like `jq`, `sops`, `deadnix`, and `statix` are available.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Features](#features)
3. [Customization](#customization)
4. [Exported Packages](#exported-packages)
5. [Screenshots](#screenshots)
6. [Resources](#resources)
7. [CI & Reproducibility](#ci--reproducibility)
8. [Raspberry Pi 4 SD Image](#raspberry-pi-4-sd-image)

## Getting Started

Before diving in, ensure that you have Nix installed on your system. If not, you
can download and install it from the official
[Nix website](https://nixos.org/download.html) or from the
[Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer).
If running on macOS, you need to have Nix-Darwin installed, as well. You can
follow the installation instruction on
[GitHub](https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes).

### Clone this repository to your local machine

```bash
# New machine without git
nix-shell -p git

# Clone
git clone https://github.com/pmallapp/premsnix.git
cd premsnix

# Linux
sudo nixos-rebuild switch --flake .

# MacOS
# First run without nix-darwin:
nix run github:lnl7/nix-darwin#darwin-rebuild -- switch --flake github:pmallapp/premsnix

darwin-rebuild switch --flake .

 # With nh (Nix Helper)
nh os switch .

# With direnv
flake switch
```

## Features
This repository contains configuration and packages for the premunix systems using Nix flakes.

### SSH Host Key Management

<a href="https://github.com/pmallapp/premsnix/actions/workflows/ssh-strict.yml">
 <img src="https://img.shields.io/github/actions/workflow/status/pmallapp/premsnix/ssh-strict.yml?branch=main&label=ssh%20strict&colorA=363a4f&colorB=f5bde6&style=for-the-badge" alt="SSH Strict Status" />
</a>

Here's an overview of what my Nix configuration offers:

- **External Dependency Integrations**: configuration built with nixvim.
  - Access NUR expressions for Firefox addons and other enhancements.
  - Integration with Hyprland and other Wayland compositors.

- **macOS Support**: Seamlessly configure and manage Nix on macOS using the
  power of [Nix-darwin](https://github.com/LnL7/nix-darwin), also leveraging
  homebrew for GUI applications.

- **Home Manager**: Manage your dotfiles, home environment, and user-specific
  configurations with
  [Home Manager](https://github.com/nix-community/home-manager).

- **DevShell Support**: The flake provides a development shell (`devShell`) to
  support maintaining this flake. You can use the devShell for convenient
  development and maintenance of your Nix environment.

- **CI with Cachix**: The configuration includes continuous integration (CI)
  that pushes built artifacts to [Cachix](https://github.com/cachix/cachix).
  This ensures efficient builds and reduces the need to build dependencies on
  your local machine.

- **Utilize sops-nix**: Secret management with
  [sops-nix](https://github.com/Mic92/sops-nix) for secure and encrypted
  handling of sensitive information.

- **Headless Raspberry Pi Image**: Slimmed `rpi4` sdImage configuration with
  reduced service footprint and optional secret-provided Wi‑Fi provisioning.

## Customization

My Nix configuration is built using
[flake-parts](https://github.com/hercules-ci/flake-parts), providing a flexible
and modular approach to managing your Nix environment. Here's how it works:

- **Flake Parts Structure**: The configuration uses flake-parts to organize
  outputs into modular parts, with the main flake definition importing from the
  `flake/` directory for better organization.

- **Custom Library**: The `lib/` directory contains custom library functions and
  utilities that extend the standard nixpkgs lib, providing additional helpers
  for system configuration.

- **Package Management**: The `packages/` directory contains custom packages
  exported by the flake. Each package is built using `callPackage` and can be
  used across different system configurations.

- **Modular Configurations**: The `modules/` directory defines reusable NixOS,
  Darwin, and Home Manager modules. This modular approach allows for consistent
  configuration across different platforms and systems.

- **Overlay System**: Custom overlays in the `overlays/` directory modify and
  extend the nixpkgs package set, allowing for package customizations and
  additions.

- **System Configurations**: Host-specific configurations are organized in
  `systems/` with separate directories for different architectures
  (`x86_64-linux`, `aarch64-darwin`).

- **Home Configurations**: User-specific Home Manager configurations in the
  `homes/` directory, organized by user and system architecture.

- **Development Environment**: A partitioned development environment in
  `flake/dev/` provides development shells, formatting tools, and checks
  separate from the main flake outputs.

This flake-parts based approach provides excellent modularity and makes it easy
to maintain and extend the configuration while keeping related functionality
organized.

## Raspberry Pi 4 SD Image

Build the headless Raspberry Pi 4 image (aarch64):

```bash
nix build .#nixosConfigurations.rpi4.config.system.build.sdImage
```

The resulting compressed image will be under `result/` (commonly
`result/sd-image/nixos-sd-image-*.img.zst`). Decompress and write it to an SD
card (double‑check your device node):

```bash
img=$(readlink -f result/sd-image/*.img.zst)
zstd -d "$img" -c | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

Optional: Provide Wi‑Fi credentials or host/user SSH keys via sops secrets
before building. The `rpi4` host will consume (if present):

```
secrets/premsnix/rpi4/default.yaml                # General host secrets (referenced as defaultSopsFile)
secrets/hosts/rpi4/ssh_host_ed25519_key           # Host SSH key (managed-keys module)
secrets/users/pmallapp/authorized_keys            # User authorized_keys (enable manageUserAuthorizedKeys once added)
secrets/known_hosts                               # Global known_hosts (optional)
```

If a Wi‑Fi NetworkManager connection secret named
`networkmanager/home.nmconnection` exists in the host sops file, it will be
installed automatically at
`/etc/NetworkManager/system-connections/premsnix-home.nmconnection`.

To keep pure evaluation working, only enable managed user authorized_keys on
`rpi4` after the corresponding secret file has been added.

# Exported packages

Run packages directly with:

```console
nix run --extra-experimental-features 'nix-command flakes' github:pmallapp/premsnix#packageName
```

Or install from the `packages` output. For example:

```nix
# flake.nix
{
  inputs.premsnix = {
    url = "github:pmallapp/premsnix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}

# configuration.nix
{pkgs, inputs, system, ...}: {
  environment.systemPackages = [
    inputs.premsnix.packages."${system}".packageName
  ];
}
```

# Screenshots

## MacOS

<img width="1512" alt="image" src="https://github.com/pmallapp/premsnix/assets/1778670/abbd501e-60c4-46c3-927d-12890dadd811">

## NixOS

![image](https://github.com/pmallapp/premsnix/assets/1778670/34aebc9c-b053-4ccf-9540-6da5e93a77d5)

# Resources

Other configurations from where I learned and copied:

- [JakeHamilton/config](https://github.com/jakehamilton/config) *Main
  inspiration and started with
- [FelixKrats/dotfiles](https://github.com/FelixKratz/dotfiles) *Sketchybar
  design and implementation
- [Fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [NotAShelf/nyx](https://github.com/NotAShelf/nyx)

## CI & Reproducibility

Workflows:

- Format (fmt.yml): Ensures treefmt formatting + detects drift (uploads diff
  when failing)
- Lint & Flake (lint.yml): Split jobs
  - eval: flake show JSON (matrix: x86_64-linux, aarch64-linux)
  - format: second-layer drift detection + diff artifact
  - meta-lint: statix + deadnix static analysis
- Nightly Host Builds (nightly-build.yml): Builds selected systems to warm cache

Local reproduction:

```
# Formatting parity
nix build .#checks.$(nix eval --raw --expr 'builtins.currentSystem').treefmt
nix fmt

# Lint parity
nix develop -c statix check .
nix develop -c deadnix .

# System build (example)
nix build .#nixosConfigurations.premsnix.config.system.build.toplevel
```

Branch protection recommendation:

1. Require fmt + lint workflows to pass on main-protected branches.
2. Optionally require Nightly Host Builds for release branches.
3. Enable mandatory status checks before merge (GitHub settings) referencing
   these workflows.
4. Treat formatting drift failures as non-mergeable until `nix fmt` re-run
   locally.

Artifacts:

- Formatting diff: `formatting-diff.patch` & file list when drift detected.
- Flake evaluation: `flake-show-<system>.json` for each matrix system.
