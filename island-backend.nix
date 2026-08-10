{
  stdenv,
  cmake,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation {
  pname = "island-backend";
  version = "1.0.0";
  src = ./.;
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
}
