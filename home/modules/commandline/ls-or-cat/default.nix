{
  pkgs,
  lib,
  config,
  ...
}:

let
  getOrDefault =
    set: attr: default:
    if set ? ${attr} then set.${attr} else default;
  ls = getOrDefault config.home.shellAliases "ll" (getOrDefault config.home.shellAliases "ls" "ls");
  cat = getOrDefault config.home.shellAliases "cat" "cat";

  # ls = lib.getExe pkgs.eza;
  # cat = lib.getExe pkgs.bat;

  ls-or-cat = pkgs.ls-or-cat.override {
    inherit ls cat;
  };
in
{
  home.packages = [ ls-or-cat ];

  home.shellAliases = {
    l = "ls-or-cat";
  };
}
