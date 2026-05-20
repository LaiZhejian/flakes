{ pkgs, inputs, ... }:

let
  codex = pkgs.pnpmCli.override {
    name = "codex";
    npmPkgName = "@openai/codex";
  };
in
{
  home.mutableFile.".codex/config.toml" = {
    format = "toml";
    ownership = {
      default = "sealed";
      rules = [
        {
          path = [ "projects" ];
          mode = "local";
        }
        {
          path = [ "mcp_servers" ];
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

  sops.secrets.ai_api_keys = {
    sopsFile = ./apikeys.enc;
    format = "binary";
  };

  home.packages = [
    codex
  ];
}
