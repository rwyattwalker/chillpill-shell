  { pkgs ? import <nixpkgs> {} }:

  let
    islandBackend = pkgs.callPackage ./island-backend.nix {};
  in
  pkgs.stdenv.mkDerivation {
    pname = "chillpill-shell";
    version = "0.3.2";

    src = ./.;

    nativeBuildInputs = [
      pkgs.makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/chillpill-shell
      mkdir -p $out/share/applications
      mkdir -p $out/bin

      cp -r qml/* $out/share/chillpill-shell/
      cp -r scripts $out/share/chillpill-shell/
      cp -r share $out/share/chillpill-shell/
      cp config.jsonc $out/share/chillpill-shell/config.jsonc.example

      makeWrapper ${pkgs.quickshell}/bin/qs $out/bin/chillpill-shell \
        --set QML_IMPORT_PATH "${islandBackend}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml" \
        --set CHILLPILL_SHELL_DIR "$out/share/chillpill-shell" \
        --add-flags "-p $out/share/chillpill-shell"

      substitute chillpill.desktop $out/share/applications/chillpill.desktop \
        --replace-fail "/usr/local/bin/chillpill-shell" "$out/bin/chillpill-shell" \
        --replace-fail "/usr/share/chillpill-shell/share/logo.png" "$out/share/chillpill-shell/share/logo.png"

      runHook postInstall
    '';
  }
