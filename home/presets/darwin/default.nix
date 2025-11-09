{ pkgs, ... }:

{
  imports = [
    ./preferences.nix
    # ../../modules/desktop/vscode
  ];
}
