{ pkgs, ... }:

{
  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-marketplace; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
