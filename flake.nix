{
  description = "Yandex Music Desktop App for NixOS and macOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
        in
        {
          yandex-music = if isDarwin
            then pkgs.callPackage ./yandex-music/darwin.nix { }
            else pkgs.callPackage ./yandex-music/linux.nix { };
            
          default = self.packages.${system}.yandex-music;
        }
      );
    };
}
