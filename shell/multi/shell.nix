{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    gdb
    gnumake
    cmake
    rustc
    cargo
    nodejs
    python3
    jdk17_headless
    maven
    gradle
  ];
}
