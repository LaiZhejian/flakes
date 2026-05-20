{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = map lib.custom.fromFlakeRoot [
    "system/presets/minimal"
    "system/modules/homebrew"
    "system/modules/base/font/fonts.nix"
    "system/presets/users/dream.nix"
  ];

  time.timeZone = "Asia/Shanghai";

  # Allow sudo authentication with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  hostSpec.users.dream.homeConfiguration = lib.custom.fromFlakeRoot "home/top/darwin/darwin-a.nix";

  # nix integration for zsh and fish
  programs.zsh.enable = true;
  programs.fish.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    stateVersion = 5;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  };
}
