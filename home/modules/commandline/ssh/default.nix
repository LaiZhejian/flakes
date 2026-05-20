{ pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    package = pkgs.openssh;
    includes = [ "config.d/*" ];
    matchBlocks = {
      # "*" = {
      #   serverAliveInterval = 15;
      #   serverAliveCountMax = 120;
      # };
      "github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };

  home.packages = lib.mkIf pkgs.stdenv.isLinux [
    pkgs.sshfs
  ];
}
