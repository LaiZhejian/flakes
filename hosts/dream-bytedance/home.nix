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

  # Dream's base uses mkForce (priority 50); these host-specific settings win.
  programs.ssh.settings = lib.mkOverride 40 {
    "github.com" = {
      hostname = "github.com";
      user = "git";
    };
    "code.byted.org" = {
      hostname = "code.byted.org";
      user = "git";
      identityFile = "~/.ssh/id_rsa";
      identitiesOnly = true;
    };
  };

  programs.uv.settings = lib.mkOverride 40 {
    pip.index-url = "https://bytedpypi.byted.org/simple/";
    index = [
      {
        url = "https://bytedpypi.byted.org/simple/";
        default = true;
      }
    ];
    pip.link-mode = "clone";
  };
}
