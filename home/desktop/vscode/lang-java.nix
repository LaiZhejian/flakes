{ pkgs, ... }:

{
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-marketplace; [
      redhat.java
      vscjava.vscode-gradle
      vscjava.vscode-java-debug
      vscjava.vscode-maven
      vscjava.vscode-java-test
      vscjava.vscode-java-dependency
    ];

    userSettings = {
      "files.exclude" = {
        "**/.classpath" = true;
        "**/.factorypath" = true;
        "**/.project" = true;
        "**/.settings" = true;
      };

      "remote.SSH.defaultExtensions" = [
        "redhat.java"
        "vscjava.vscode-gradle"
      ];
    };
  };
}
