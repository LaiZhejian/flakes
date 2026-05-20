{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
  ];

  # File explorer
  programs.thunar.enable = true;
  # Thunbnail generation
  services.tumbler.enable = true;
  # Mount, trashbin, etc.
  services.gvfs.enable = true;
}
