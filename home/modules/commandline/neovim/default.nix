{ lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    withRuby = false;
    withPython3 = false;
  };

  xdg.configFile.nvim = lib.mkIf (builtins.pathExists ./nvim-config) {
    source = ./nvim-config;
  };
}
