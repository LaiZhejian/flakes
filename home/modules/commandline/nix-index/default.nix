{ config, pkgs, ... }:

{
  # A replacement for command-not-found in nix
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
