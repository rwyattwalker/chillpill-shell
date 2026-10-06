{
  pkgs ? import <nixpkgs> { },
}:

let
  islandBackend = pkgs.callPackage ./island-backend.nix { };
in
pkgs.stdenv.mkDerivation {
  pname = "nix-pill";
  version = "0.3.2";

  src = ./.;

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nix-pill
    mkdir -p $out/share/applications
    mkdir -p $out/bin

    cp -r qml/* $out/share/nix-pill/
    cp -r scripts $out/share/nix-pill/
    cp -r share $out/share/nix-pill/
    cp config.jsonc $out/share/nix-pill/config.jsonc.example

    makeWrapper ${pkgs.quickshell}/bin/qs $out/bin/nix-pill \
      --set QML_IMPORT_PATH "${islandBackend}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml" \
      --set NIXPILL_SHELL_DIR "$out/share/nix-pill" \
      --add-flags "-p $out/share/nix-pill"

    runHook postInstall
  '';

}
