{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, electron
, libayatana-appindicator
, asar
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
    asar
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/yandex-music
    cp opt/Яндекс\ Музыка/resources/app.asar $out/share/yandex-music/
    cp -r opt/Яндекс\ Музыка/resources/assets $out/share/yandex-music/

    # Patch process.resourcesPath in app.asar to point to $out/share/yandex-music
    # This is required because we run the app using system electron, which changes process.resourcesPath
    asar extract $out/share/yandex-music/app.asar $out/share/yandex-music/app
    substituteInPlace $out/share/yandex-music/app/index.js \
      --replace-warn "process.resourcesPath" "require('path').join(__dirname, '..')"
    asar pack $out/share/yandex-music/app $out/share/yandex-music/app.asar
    rm -rf $out/share/yandex-music/app

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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}" \
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
