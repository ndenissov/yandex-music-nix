#!/usr/bin/env bash
set -e

# Fetch latest version from release notes
LATEST_VERSION=$(curl -s https://desktop.app.music.yandex.net/stable/release-notes/en.json | grep -oP '"version": "\K[^"]+' | head -n 1)

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to fetch latest version."
    exit 1
fi

echo "Latest version is $LATEST_VERSION"

# Define URLs
LINUX_URL="https://desktop.app.music.yandex.net/stable/Yandex_Music_amd64_${LATEST_VERSION}.deb"
DARWIN_URL="https://desktop.app.music.yandex.net/stable/Yandex_Music_universal_${LATEST_VERSION}.dmg"

echo "Prefetching Linux DEB..."
LINUX_HASH=$(nix hash to-sri --type sha256 $(nix-prefetch-url "$LINUX_URL" 2>/dev/null))

echo "Prefetching Darwin DMG..."
DARWIN_HASH=$(nix hash to-sri --type sha256 $(nix-prefetch-url "$DARWIN_URL" 2>/dev/null))

echo "Updating linux.nix..."
sed -i -E "s/version = \".+\";/version = \"$LATEST_VERSION\";/" yandex-music/linux.nix
sed -i -E "s|hash = \".+\";|hash = \"$LINUX_HASH\";|" yandex-music/linux.nix

echo "Updating darwin.nix..."
sed -i -E "s/version = \".+\";/version = \"$LATEST_VERSION\";/" yandex-music/darwin.nix
sed -i -E "s|hash = \".+\";|hash = \"$DARWIN_HASH\";|" yandex-music/darwin.nix

echo "Done!"
