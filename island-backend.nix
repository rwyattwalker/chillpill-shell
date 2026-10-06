{
  stdenv,
  cmake,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation {
  pname = "island-backend";
  version = "1.0.0";
  src = builtins.path {
    path = ./.;
    name = "nix-pill-src";
    filter =
      path: type:
      let
        base = baseNameOf path;
      in
      base != "build" && base != "result" && base != ".cache";
  };
  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qtbase
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qt-6/qml/IslandBackend

    cp ./libIslandBackend.so $out/lib/qt-6/qml/IslandBackend/
    cp ./IslandBackend/libIslandBackendPlugin.so $out/lib/qt-6/qml/IslandBackend/
    cp ./IslandBackend/qmldir $out/lib/qt-6/qml/IslandBackend/
    cp ./IslandBackend/IslandBackend.qmltypes $out/lib/qt-6/qml/IslandBackend/

    runHook postInstall
  '';
}
