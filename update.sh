#!/usr/bin/env bash
set -euo pipefail

# Получаем версии из официальных манифестов автообновления Яндекса
LINUX_VERSION=$(curl -fsSL https://desktop.app.music.yandex.net/stable/latest-linux.yml | sed -n 's/^version: \(.*\)$/\1/p')
DARWIN_VERSION=$(curl -fsSL https://desktop.app.music.yandex.net/stable/latest-mac.yml | sed -n 's/^version: \(.*\)$/\1/p')

if [ -z "$LINUX_VERSION" ] || [ -z "$DARWIN_VERSION" ]; then
    echo "Failed to fetch latest versions."
    exit 1
fi

echo "Latest Linux version:  $LINUX_VERSION"
echo "Latest Darwin version: $DARWIN_VERSION"

# Ссылки на дистрибутивы
LINUX_URL="https://desktop.app.music.yandex.net/stable/Yandex_Music_amd64_${LINUX_VERSION}.deb"
DARWIN_URL="https://desktop.app.music.yandex.net/stable/Yandex_Music_universal_${DARWIN_VERSION}.dmg"

echo "Prefetching Linux DEB..."
LINUX_HASH=$(nix store prefetch-file --json "$LINUX_URL" | jq -r .hash)

echo "Prefetching Darwin DMG..."
DARWIN_HASH=$(nix store prefetch-file --json "$DARWIN_URL" | jq -r .hash)

echo "Updating linux.nix..."
sed -i -E "s/version = \".+\";/version = \"$LINUX_VERSION\";/" yandex-music/linux.nix
sed -i -E "s|hash = \".+\";|hash = \"$LINUX_HASH\";|" yandex-music/linux.nix

echo "Updating darwin.nix..."
sed -i -E "s/version = \".+\";/version = \"$DARWIN_VERSION\";/" yandex-music/darwin.nix
sed -i -E "s|hash = \".+\";|hash = \"$DARWIN_HASH\";|" yandex-music/darwin.nix

echo "Done!"
