{
  pkgs ? import <nixpkgs> { system = "aarch64-darwin"; },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    gdb
    lldb
    gnumake
  ];
}
