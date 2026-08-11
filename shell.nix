{
  pkgs ? import <nixpkgs> { },
}:

let
  islandBackend = pkgs.callPackage ./island-backend.nix { };
in
pkgs.mkShell {
  inputsFrom = [ islandBackend ];

  packages = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.quickshell
    pkgs.qt6.qtbase
    pkgs.qt6.qtdeclarative
    pkgs.qt6.qtwayland
    pkgs.qt6.qtmultimedia
  ];

  shellHook = ''
    export QML_IMPORT_PATH="$PWD/build''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
  '';
}
