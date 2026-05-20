{ pkgs, config, ... }:

let
  recursiveMerge =
    attrList:
    let
      f =
        attrPath:
        with pkgs.lib;
        zipAttrsWith (
          n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (concatLists values)
          else if all isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            last values
        );
    in
    f [ ] attrList;
  extensions = pkgs.forVSCodeVersion config.programs.vscode.package.version;
in
recursiveMerge [
  pkgs.vscode-marketplace
  extensions.vscode-marketplace
  extensions.vscode-marketplace-release
]
