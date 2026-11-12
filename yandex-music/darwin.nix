{ lib
, stdenv
, fetchurl
, undmg
}:

stdenv.mkDerivation rec {
  pname = "yandex-music";
  version = "5.127.0";

  src = fetchurl {
    url = "https://desktop.app.music.yandex.net/stable/Yandex_Music_universal_${version}.dmg";
    hash = "sha256-v/jCKcsY6LXVAxyoBfRZji6w/FmZlQR2jl1MWz8It88=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "Yandex Music.app" $out/Applications/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Yandex Music Desktop App";
    homepage = "https://music.yandex.ru/";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "Yandex Music";
  };
}
