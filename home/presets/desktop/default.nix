{ pkgs, ... }:

{
  imports = [
    ../../modules/desktop/hyprland
    ../../modules/desktop/mako
    # ../../modules/desktop/eww
    ../../modules/desktop/waybar
    ../../modules/desktop/input

    ../../modules/desktop/foot
    ../../modules/desktop/wezterm
    ../../modules/desktop/vscode
    # ../../modules/desktop/wpsoffice
    ../../modules/desktop/firefox
    ../../modules/desktop/thunderbird

    ../../modules/desktop/zotero
    ../../modules/desktop/obsidian
    ../../modules/desktop/obs
  ];

  home.packages = with pkgs; [
    polkit # for pkexec, used by clash-verge-rev

    sparkle # clash client

    localsend
    qq
    wechat
  ];
}
