{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, electron
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
    makeWrapper
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/yandex-music
    cp opt/Яндекс\ Музыка/resources/app.asar $out/share/yandex-music/

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
    makeWrapper ${electron}/bin/electron $out/bin/yandex-music \
      --add-flags "$out/share/yandex-music/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Yandex Music Desktop App";
    homepage = "https://music.yandex.ru/";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "yandex-music";
  };
}
