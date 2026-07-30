{
  config,
  pkgs,
  lib,
  ...
}:

let
  codex = pkgs.pnpmCli.override {
    name = "codex";
    npmPkgName = "@openai/codex";
  };
in
{
  options.custom.home.stacks.commandline.codex = {
    enable = lib.mkEnableOption "Enable codex.";
  };

  config = lib.mkIf config.custom.home.stacks.commandline.codex.enable {
    home.mutableFile.".codex/config.toml" = {
      format = "toml";
      ownership = {
        default = "sealed";
        rules = [
          {
            path = [ "projects" ];
            mode = "local";
          }
        ];
      };
      layers = [
        {
          source = ./config.toml;
        }
      ];
    };

    home.packages = [
      codex
    ];
  };
}
