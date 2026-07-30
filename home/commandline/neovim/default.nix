{ config, lib, ... }:

{
  options.custom.home.stacks.commandline.neovim = {
    enable = lib.mkEnableOption "Enable neovim.";
    defaultEditor = lib.mkEnableOption "Make neovim the default editor.";
  };

  config = lib.mkIf config.custom.home.stacks.commandline.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = config.custom.home.stacks.commandline.neovim.defaultEditor;

      withRuby = false;
      withPython3 = false;
    };

    xdg.configFile.nvim =
      lib.mkIf (builtins.pathExists ./nvim-config && builtins.readDir ./nvim-config != { })
        {
          source = ./nvim-config;
        };
  };
}
