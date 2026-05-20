#/usr/bin/env bash

export GOOD=eac9adc9cc293c4cec9686f9ae534cf21a5f7c7e
export BAD=b8197e259ad1b49d63789b7fdb8214644b1b05de
export SYSTEM=aarch64-darwin
export PACKAGE=zotero

GOOD_PATH=$(nix-instantiate --eval --raw --expr 'fetchTarball "https://github.com/NixOS/nixpkgs/archive/'"$GOOD"'.tar.gz"')
BAD_PATH=$(nix-instantiate --eval --raw --expr 'fetchTarball "https://github.com/NixOS/nixpkgs/archive/'"$BAD"'.tar.gz"')
echo "Good Nixpkgs: $GOOD_PATH"
echo "Bad Nixpkgs: $BAD_PATH"

GOOD_DRV=$(nix-instantiate --raw --expr '
let
  pkgs = import "'"$GOOD_PATH"'" { system = "'"$SYSTEM"'"; };
in pkgs.'"$PACKAGE"'
')
BAD_DRV=$(nix-instantiate --raw --expr '
let
  pkgs = import "'"$BAD_PATH"'" { system = "'"$SYSTEM"'"; };
in pkgs.'"$PACKAGE"'
')
echo "Good drv: $GOOD_DRV"
echo "Bad drv: $BAD_DRV"

nix-shell -p nix-diff --run 'nix-diff '"$GOOD_DRV"' '"$BAD_DRV"

