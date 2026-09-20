{
  inputs,
  lib,
}:

let
  inherit (lib)
    concatMapAttrs
    optionalAttrs
    concatStringsSep
    hasSuffix
    filterAttrs
    mapAttrs
    pathExists
    ;

  flatMapRecursive =
    {
      stopFn,
      mapFn,
      path ? [ ],
    }@args:
    attr:
    if stopFn path attr then
      mapFn path attr
    else
      attr |> concatMapAttrs (name: value: flatMapRecursive (args // { path = path ++ [ name ]; }) value);
  processDirRecursive =
    {
      stopFn ? (path: type: false),
      mapFn,
      directory,
    }@args:
    builtins.readDir directory
    |> concatMapAttrs (
      name: type:
      # for each directory entry
      let
        path = directory + "/${name}";
        stop = stopFn path type;
        current = mapFn path type;
        recursive = optionalAttrs (!stop && type == "directory") (
          processDirRecursive (
            args
            // {
              directory = path;
            }
          )
        );
        final = current // recursive;
        isEmpty = final == { };
      in
      optionalAttrs (final != { }) {
        "${name}" = final;
      }
    );
  hosts =
    processDirRecursive {
      directory = ./.;
      stopFn = path: type: pathExists (path + "/meta.nix");
      mapFn =
        path: type:
        optionalAttrs (pathExists (path + "/meta.nix")) (import (path + "/meta.nix") // { path = path; });
    }
    |> flatMapRecursive {
      stopFn = path: attr: attr ? path;
      mapFn = path: attr: {
        "${lib.concatStringsSep "-" path}" = attr;
      };
    };

  buildSystemConfiguration =
    builder: meta:
    builder {
      specialArgs = {
        inherit lib;
        inherit inputs;
        hostMeta = meta;
        isLinux = hasSuffix "-linux" meta.platform;
        isDarwin = hasSuffix "-darwin" meta.platform;
      };
      modules = [
        ../system
        ./user.nix
        (meta.path + "/system.nix")
      ];
    };

  buildHomeConfiguration =
    meta:
    inputs.home-manager.lib.homeManagerConfiguration {
      # Let Home Manager extend our custom library with lib.hm.
      inherit lib;
      pkgs = inputs.nixpkgs.legacyPackages.${meta.platform};
      extraSpecialArgs = {
        inherit inputs;
        hostMeta = meta;
        isLinux = hasSuffix "-linux" meta.platform;
        isDarwin = hasSuffix "-darwin" meta.platform;
      };
      modules = [
        ../home
        (meta.path + "/home.nix")
      ];
    };

  nixosConfigurations =
    hosts
    |> filterAttrs (_: host: host.kind == "nixos")
    |> mapAttrs (_: host: buildSystemConfiguration lib.nixosSystem host);
  darwinConfigurations =
    hosts
    |> filterAttrs (_: host: host.kind == "darwin")
    |> mapAttrs (_: host: buildSystemConfiguration inputs.darwin.lib.darwinSystem host);
  homeConfigurations =
    hosts
    |> filterAttrs (_: host: host.kind == "home")
    |> mapAttrs (_: host: buildHomeConfiguration host);
in
{
  inherit
    hosts
    nixosConfigurations
    darwinConfigurations
    homeConfigurations
    ;
}
