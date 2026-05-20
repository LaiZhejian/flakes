{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
    ];
  };

  home.shellAliases = {
    cat = "bat";
    man = "batman";
  };
}
