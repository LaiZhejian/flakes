{
  pkgs ? import <nixpkgs> { },
  name ? "pnpm",
  npmPkgName ? name,
}:
pkgs.writeShellApplication {
  name = name;
  runtimeInputs = [
    pkgs.nodejs
    pkgs.pnpm
  ];
  text = ''
    if [[ -n "''${XDG_CACHE_HOME:-}" ]]; then
      cache_dir="$XDG_CACHE_HOME/pnpmCli"
    else
      cache_dir="$HOME/.cache/pnpmCli"
    fi

    # Check if a cached version exists and is less than 24 hours old
    latest_version=""
    if (find "$cache_dir/${npmPkgName}/version" -mmin -1440 -print -quit 2>/dev/null || true) | grep -q .; then
      latest_version=$(cat "$cache_dir/${npmPkgName}/version")
      # echo "Using cached version: ${npmPkgName}@$latest_version"
    fi

    if [[ -z "$latest_version" && -n "''${PNPM_NO_UPDATE:-}" ]]; then
      if [[ -f "$cache_dir/${npmPkgName}/version" ]]; then
        latest_version=$(cat "$cache_dir/${npmPkgName}/version")
      fi
    fi

    if [[ -z "$latest_version" ]]; then
      latest_version=$(pnpm view "${npmPkgName}@latest" dist-tags.latest)
      # echo "${npmPkgName} is updated to $latest_version"
      mkdir -p "$cache_dir/${npmPkgName}"
      echo "$latest_version" > "$cache_dir/${npmPkgName}/version"
    fi

    exec pnpm dlx -- "${npmPkgName}@""$latest_version" "$@"
  '';
}
