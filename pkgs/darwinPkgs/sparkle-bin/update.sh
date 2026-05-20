#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix curl coreutils common-updater-scripts gnused gnugrep jq

set -euo pipefail
set -x

repo="xishang0128/sparkle"
nix_file="$(dirname "$0")/package.nix"
release_json="$(curl -vfsSL "https://api.github.com/repos/${repo}/releases/latest")"
latest_tag="$(jq -r .tag_name <<<"$release_json")"
if [[ -z "${latest_tag}" || "${latest_tag}" == "null" ]]; then
  echo "Failed to fetch latest release tag from GitHub"
  exit 1
fi
version="${latest_tag#v}"
linux_x86_64_asset="sparkle-linux-${version}-amd64.deb"
linux_aarch64_asset="sparkle-linux-${version}-arm64.deb"
darwin_x86_64_asset="sparkle-macos-${version}-x64.pkg"
darwin_aarch64_asset="sparkle-macos-${version}-arm64.pkg"
for asset in \
  "$linux_x86_64_asset" \
  "$linux_aarch64_asset" \
  "$darwin_x86_64_asset" \
  "$darwin_aarch64_asset"
do
  if ! jq -e --arg name "$asset" '.assets[] | select(.name == $name)' <<<"$release_json" >/dev/null; then
    echo "Missing expected asset in latest release: $asset"
    exit 1
  fi
done
prefetch_sri() {
  local url="$1"
  nix-prefetch-url --type sha256 "$url" | xargs nix hash to-sri --type sha256
}
base_url="https://github.com/${repo}/releases/download/${latest_tag}"
linux_x86_64_hash="$(prefetch_sri "${base_url}/${linux_x86_64_asset}")"
linux_aarch64_hash="$(prefetch_sri "${base_url}/${linux_aarch64_asset}")"
darwin_x86_64_hash="$(prefetch_sri "${base_url}/${darwin_x86_64_asset}")"
darwin_aarch64_hash="$(prefetch_sri "${base_url}/${darwin_aarch64_asset}")"
echo "Updating sparkle to ${version}"
sed -i -E \
  -e "s/version = \".*\";/version = \"${version}\";/" \
  -e "/x86_64-linux = /s|sha256-[^\"]+|${linux_x86_64_hash}|" \
  -e "/aarch64-linux = /s|sha256-[^\"]+|${linux_aarch64_hash}|" \
  -e "/x86_64-darwin = /s|sha256-[^\"]+|${darwin_x86_64_hash}|" \
  -e "/aarch64-darwin = /s|sha256-[^\"]+|${darwin_aarch64_hash}|" \
  "$nix_file"
echo "Updated ${nix_file}"

