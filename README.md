# Yandex Music NixOS Flake

This is a standalone, native NixOS flake for installing and running the official Yandex Music desktop application on Linux and macOS.

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

The derivation uses `autoPatchelfHook` on Linux to dynamically link the pre-built Electron binaries with NixOS libraries (such as `alsa-lib`, `vulkan-loader`, `libx11`, etc.). On macOS, it extracts the `.dmg` using `undmg` and installs the `.app` bundle.

## Known Issues

- **SIGSEGV on close**: When closing the app via the system tray under a Wayland session, the app may crash (`SIGSEGV` / `Address boundary error`). This is an upstream Electron bug related to Ozone Wayland and idle inhibitors. It is entirely harmless and does not affect playback or cause data loss.
