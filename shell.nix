{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
    packages = with pkgs; [
        gcc
        cmake
        gnumake
        qt6.qtbase
        qt6.qtdeclarative
    ];
}
