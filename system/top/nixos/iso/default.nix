{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ]
  ++ map lib.custom.fromFlakeRoot [
    "system/presets/commandline"
    "system/presets/users/lh.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # isoImage.squashfsCompression = "xz -Xdict-size 100%"; # default 2.9G
  # isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  # isoImage.squashfsCompression = "zstd -b 32768 -Xcompression-level 22"; # 3.5G
}
