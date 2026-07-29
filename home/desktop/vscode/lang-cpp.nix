{ pkgs, ... }:

{
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-marketplace; [
      llvm-vs-code-extensions.vscode-clangd
      # vadimcn.vscode-lldb
    ];

    userSettings = {
      "[c]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
      "[cpp]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };

      "remote.SSH.defaultExtensions" = [
        "llvm-vs-code-extensions.vscode-clangd"
      ];
    };
  };
}
