{
  config,
  lib,
  pkgs,
  ...
}:

let
  secretBootstrap =
    pkgs.runCommand "zotero-flake-secrets.xpi" { nativeBuildInputs = [ pkgs.zip ]; }
      ''
        cd ${./secret-extension}
        zip -qr "$out" .
      '';
in
{
  home.file.".local/share/zotero/extensions" = {
    source = ./extensions;
    recursive = true;
  };
  home.file.".local/share/zotero/extensions/zotero-flake-secrets@dream.xpi".source = secretBootstrap;

  home.activation.installZoteroExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    zotero_profiles="${config.home.homeDirectory}/Library/Application Support/Zotero/Profiles"
    extension_source="${config.home.homeDirectory}/.local/share/zotero/extensions"

    if [ -d "$zotero_profiles" ]; then
      for zotero_profile in "$zotero_profiles"/*.default*; do
        if [ -d "$zotero_profile" ]; then
          $DRY_RUN_CMD mkdir -p "$zotero_profile/extensions"
          for extension in "$extension_source"/*.xpi; do
            if [ -e "$extension" ]; then
              $DRY_RUN_CMD ln -sfn "$extension" "$zotero_profile/extensions/$(basename "$extension")"
            fi
          done
        fi
      done
    fi
  '';
}
