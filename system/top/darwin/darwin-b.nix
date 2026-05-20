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

  hostSpec.users.dream = {
    name = lib.mkForce "bytedance";
    homeConfiguration = lib.custom.fromFlakeRoot "home/top/darwin/darwin-b.nix";
  }

  hostSpec.primaryUser = lib.mkForce "bytedance";

  # nix integration for zsh and fish
  programs.zsh.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    stateVersion = 5;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  };
}
