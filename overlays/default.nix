{ inputs, ... }:

let
  override_package =
    pkgs: package: package.override (builtins.intersectAttrs package.override.__functionArgs pkgs);
in
{
  vscode-marketplace = inputs.nix-vscode-extensions.overlays.default;
  nur = inputs.nur.overlays.default;

  myPackages =
    final: prev:
    inputs.nixpkgs.lib.packagesFromDirectoryRecursive {
      callPackage = inputs.nixpkgs.lib.callPackageWith final;
      directory = ../pkgs;
    };

  darwin =
    final: prev:
    prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      clash-verge-rev = final.darwinPkgs.clash-verge-rev;
      sparkle = final.darwinPkgs.sparkle-bin;
      # The pinned nixpkgs QQ DMG was removed upstream (HTTP 404).
      # Keep this source aligned with nixpkgs 20b1ddd until the input is updated.
      qq =
        if prev.lib.versionOlder prev.qq.version "7.0.0-2026-08-12" then
          prev.qq.overrideAttrs (_: {
            version = "7.0.0-2026-08-12";
            src = final.fetchurl {
              url = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.33/release/126b7ce6/QQ_7.0.0_260812_01.dmg";
              hash = "sha256-sZXCbfNir1iVTImKsd2YR4Sium9Xpinm+5s+zDv55lw=";
            };
          })
        else
          prev.qq;
    };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

}
