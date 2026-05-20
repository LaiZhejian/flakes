{ pkgs, ... }:

{
  imports = [
    ../../presets/commandline
    ../../presets/darwin
  ];

  home.packages = with pkgs; [
    kubectl
  ];

  programs.git.signing.signByDefault = false;
}
