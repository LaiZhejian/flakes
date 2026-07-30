{
  config,
  lib,
  ...
}:

{
  # The ByteDance account uses Dream's personal Home Manager defaults.
  imports = [
    ../dream/home.nix
  ];

  # Keep executables installed by company tooling available in every shell.
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  # Keep Codex installed, but let this machine retain its account, provider,
  # plugin and project state instead of inheriting Dream's provider settings.
  custom.home.stacks.commandline.codex.enable = lib.mkOverride 40 true;
  home.mutableFile.".codex/config.toml" = {
    ownership = lib.mkForce {
      default = "sealed";
      rules = map
        (path: {
          path = [ path ];
          mode = "local";
        })
        [
          "model"
          "model_reasoning_effort"
          "notify"
          "features"
          "desktop"
          "marketplaces"
          "plugins"
          "shell_environment_policy"
          "hooks"
          "projects"
          "mcp_servers"
        ];
    };
    layers = lib.mkForce [
      {
        source = ./codex.toml;
      }
    ];
  };

}
