{ user, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./presets/commandline
  ];

  home.username = pkgs.lib.mkDefault user;
  home.homeDirectory = pkgs.lib.mkDefault (
    if pkgs.stdenv.isDarwin
    then "/Users/${user}"
    else "/home/${user}"
  );
}
