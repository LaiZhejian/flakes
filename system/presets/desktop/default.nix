{ pkgs, ... }:

{
  imports = [
    ../commandline

    ../../modules/base/font
    ../../modules/desktop/wayland
    ../../modules/desktop/hyprland
    ../../modules/desktop/thunar
    ../../modules/hardware
    ./common-apps.nix
  ];

  programs.clash-verge = {
    enable = true;
    autoStart = true;
  };
}
