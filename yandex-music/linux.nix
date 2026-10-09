{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libayatana-appindicator
, libcxx
, libdrm
, libnotify
, libpulseaudio
, libsecret
, libuuid
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, udev
, wayland
, libGL
, vulkan-loader
, xdg-utils
, libx11
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxrandr
, libxrender
, libxtst
, libxcb
, libxshmfence
}:

stdenv.mkDerivation rec {
  pname = "yandex-music";
  version = "5.122.0";

  src = fetchurl {
    url = "https://desktop.app.music.yandex.net/stable/Yandex_Music_amd64_${version}.deb";
    hash = "sha256-kJEzmWGJlDEm9epRixeKuvPTPbom56g6j1vhKZDcQ+M=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libayatana-appindicator
    libcxx
    libdrm
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    udev
    wayland
    libGL
    vulkan-loader
    xdg-utils
  ] ++ [
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r opt/Яндекс\ Музыка $out/share/yandex-music
    cp -r usr/share/applications $out/share/
    cp -r usr/share/icons $out/share/

    # Rename the desktop file to perfectly match the old implementation
    mv $out/share/applications/yandexmusic.desktop $out/share/applications/yandex-music.desktop

    # Fix desktop file: replace absolute path, fix Wayland icon (StartupWMClass), and rename to English
    substituteInPlace $out/share/applications/yandex-music.desktop \
      --replace-fail "/opt/Яндекс Музыка/yandexmusic" "$out/bin/yandex-music" \
      --replace-fail "Name=Яндекс Музыка" "Name=Yandex Music" \
      --replace-fail "StartupWMClass=Яндекс Музыка" "StartupWMClass=yandexmusic"

    # Make the wrapper
    makeWrapper $out/share/yandex-music/yandexmusic $out/bin/yandex-music \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Yandex Music Desktop App";
    homepage = "https://music.yandex.ru/";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "yandex-music";
  };
}
