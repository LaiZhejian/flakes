{ config, ... }:

{
  # The ByteDance account uses Dream's personal Home Manager defaults.
  imports = [
    ../dream/home.nix
  ];

  # Keep executables installed by company tooling available in every shell.
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

}
