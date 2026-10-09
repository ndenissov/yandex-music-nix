# Yandex Music NixOS Flake

<div align="center">
  <img src="https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=NixOS&logoColor=white" alt="NixOS" />
  <img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS" />
  <img src="https://img.shields.io/github/actions/workflow/status/ndenissov/yandex-music-nix/release.yml?style=for-the-badge&label=Releases" alt="Releases" />
</div>

This is a standalone, native NixOS flake for installing and running the official Yandex Music desktop application on Linux and macOS. 
It serves as a modern, actively maintained replacement for the now-archived [cucumber-sp/yandex-music-linux](https://github.com/cucumber-sp/yandex-music-linux).

Unlike older repackaging solutions that relied on extracting the Windows ASAR, this project uses the official `.deb` (for Linux) and `.dmg` (for macOS) native clients provided by Yandex.

## Features

- **Native Linux & macOS Support**: Uses the official `amd64` `.deb` package and `universal` `.dmg` package respectively.
- **Wayland Support**: Includes automatic fixes for Wayland icons and Ozone decorations.
- **System Tray & MPRIS**: Tray works beautifully, and media controls (play/pause/next) integrate out of the box.
- **Auto-Updates**: A built-in GitHub Actions workflow checks for new updates daily and creates automated pull requests.

## Usage

### Run without installing (Nix Flakes)

You can run the app directly using `nix run`:

```bash
nix run github:ndenissov/yandex-music-nix
```

*Note: Running the app directly via `nix run` will not install the `.desktop` file globally, which means Wayland compositors and desktop environments might not show the correct icon in your dock. For the full experience, consider adding it to your system packages.*

### Install to system (NixOS)

Add this flake to your `flake.nix` inputs:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  yandex-music = {
    url = "github:ndenissov/yandex-music-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

And then add the package to your `environment.systemPackages` or Home Manager `home.packages`:

```nix
environment.systemPackages = [
  inputs.yandex-music.packages.${pkgs.system}.default
];
```

## How it works

On Linux, this flake downloads the official `.deb` release, extracts the `app.asar` source code along with its tray assets, and runs it natively using the Nixpkgs `electron` package. This ensures perfect integration with Wayland, system certificates, and GSettings, while bypassing the bugs present in Yandex's bundled Electron binary.

On macOS, it extracts the `.dmg` using `undmg` and installs the `.app` bundle natively.
