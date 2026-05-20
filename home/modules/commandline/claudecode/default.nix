{
  pkgs,
  ...
}:

let
  claude = pkgs.pnpmCli.override {
    name = "claude";
    npmPkgName = "@anthropic-ai/claude-code";
  };
in
{
  home.packages = [
    claude
  ];

  home.file.".config/ccstatusline/settings.json".source = ./ccstatusline.json;
}
