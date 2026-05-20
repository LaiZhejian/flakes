{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ]
  ++ map lib.custom.fromFlakeRoot [
    "system/presets/commandline"
    "system/presets/users/lh.nix"
  ];

  hostSpec.users.lh.homeConfiguration = lib.custom.fromFlakeRoot "home/top/nixos/wsl.nix";

  wsl.enable = true;
  wsl.defaultUser = config.hostSpec.primaryUser;

  wsl.docker-desktop.enable = false;
  wsl.usbip.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
