{ lib
, stdenv
, fetchurl
, undmg
}:

stdenv.mkDerivation rec {
  pname = "yandex-music";
  version = "5.128.0";

  src = fetchurl {
    url = "https://desktop.app.music.yandex.net/stable/Yandex_Music_universal_${version}.dmg";
    hash = "sha256-6LLtnh2SHfA1HmQZjeeTupqWcGdoE3hZ9C/uduJeqEw=";
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
