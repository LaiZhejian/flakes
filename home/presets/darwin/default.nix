{ pkgs, ... }:

{
  imports = [
    ../../modules/misc

    ./preferences.nix
    # ../../modules/desktop/vscode
  ];

  home.packages = with pkgs; [
    raycast
    keka
    sparkle

    qq
    wechat
  ];
}
