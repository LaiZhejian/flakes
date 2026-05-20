{ pkgs, ... }:

{
  imports = [
    ../../modules/base/misc
    ../../modules/base/user
    ../../modules/base/nix
    ../../modules/base/console
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
}
