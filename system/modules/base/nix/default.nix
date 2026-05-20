{
  pkgs,
  lib,
  inputs,
  user,
  ...
}:

{
  nix = {
    settings = {
      trusted-users = [
        "@admin"
        "@sudo"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://undefined01.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "undefined01.cachix.org-1:9ZQ59dYp2cR8S5p87DaKqjtIyjZ1qMHmM2JtzpQl1dU="
      ];
    };

    # Collect garbage periodically
    gc =
      let
        periodConfig =
          lib.optionalAttrs pkgs.stdenv.isLinux {
            dates = "daily";
          }
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            interval = {
              Weekday = 1;
              Hour = 0;
              Minute = 0;
            };
          };
      in
      {
        automatic = true;
        options = "--delete-older-than 30d";
      }
      // periodConfig;

    # Optimise nix store via hardlinking
    optimise.automatic = true;

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      unstable.to = {
        "type" = "github";
        "owner" = "NixOS";
        "repo" = "nixpkgs";
        "ref" = "nixos-unstable";
      };
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = builtins.attrValues (import (lib.custom.fromFlakeRoot "overlays") { inherit inputs; });
  };
}
