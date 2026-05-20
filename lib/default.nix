{ lib, ... }:

rec {
  flakeRoot = ../.;

  # get the path from the root of this flake
  fromFlakeRoot = (
    path:
    if lib.isString path then
      lib.path.append flakeRoot path
    else
      throw "lib.custom.fromFlakeRoot: expected a string, got: ${lib.typeOf path}"
  );

  # Recursively imports nix files from a directory as an attrset of packages.
  # Copied from https://github.com/NixOS/nixpkgs/blob/a338f62ea8defe7b0946f9718204c29105524b35/lib/filesystem.nix#L361:C3
  callDirectoryRecursive =
    let
      inherit (lib)
        concatMapAttrs
        pathExists
        hasSuffix
        removeSuffix
        ;

      # Generate an attrset corresponding to a given directory.
      # This function is outside `packagesFromDirectoryRecursive`'s lambda expression,
      #  to prevent accidentally using its parameters.
      processDir =
        { callFunc, directory, ... }@args:
        concatMapAttrs (
          name: type:
          # for each directory entry
          let
            path = directory + "/${name}";
          in
          if type == "directory" then
            {
              # recurse into directories
              "${name}" = callDirectoryRecursive (
                args
                // {
                  directory = path;
                }
              );
            }
          else if type == "regular" && hasSuffix ".nix" name then
            {
              # call .nix files
              "${removeSuffix ".nix" name}" = callFunc path;
            }
          else if type == "regular" then
            {
              # ignore non-nix files
            }
          else
            throw ''
              lib.filesystem.callDirectoryRecursive: Unsupported file type ${type} at path ${toString path}
            ''
        ) (builtins.readDir directory);
    in
    {
      defaultFilename ? "default.nix",
      callFunc,
      directory,
    }@args:
    let
      defaultPath = lib.path.append directory defaultFilename;
    in
    if pathExists defaultPath then
      # if `${directory}/package.nix` exists, call it directly
      callFunc defaultPath
    else
      processDir args;

  # Imports any .nix file in the specific directory, and any folder. Note this
  # means that a folder containing `default.nix` and other *.nix files is expected
  # to use the other *.nix files in that folder as supplementary, and not distinct
  # modules
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # include directories
          || (
            (path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );

  leaf = str: lib.last (lib.splitString "/" str);

  scanPathsFilterPlatform =
    path:
    lib.filter (
      path: builtins.match "nixos.nix|darwin.nix|nixos|darwin" (leaf (builtins.toString path)) == null
    ) (scanPaths path);
}
