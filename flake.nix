{
  description = "Yandex Music Desktop App for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.${system} = {
        yandex-music = pkgs.callPackage ./yandex-music/package.nix { };
        default = pkgs.callPackage ./yandex-music/package.nix { };
      };
    };
}
