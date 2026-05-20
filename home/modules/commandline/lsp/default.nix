{ pkgs, ... }:

let
  pkgs = pkgs.override {
    jdt-language-server = pkgs.unstable.jdt-language-server;
  };
in
{
  home.packages = with pkgs; [
    nodePackages.bash-language-server
    lua-language-server
    nodePackages.vscode-json-languageserver
    python3.withPackages
    (python-pkgs: [
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.python-lsp-server
    ])

    clang
    jdt-language-server
    gopls
    bash-language-server
    kotlin-language-server
    # rust-analyzer
    nodePackages.typescript-language-server

    # typst-lsp
  ];
}
