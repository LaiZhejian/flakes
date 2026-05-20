{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # imports = [ ../../programs/wayland/waybar/hyprland_waybar.nix ];

  programs = {
    dconf.enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  };

  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
  };
}
