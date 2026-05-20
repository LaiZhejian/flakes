{
  lib,
  stdenvNoCC,
  buildGoModule,
  fetchFromGitHub,
  pnpm_10,
  pnpm ? pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  makeWrapper,
  electron,
  dbip-asn-lite,
  dbip-country-lite,
  v2ray-geoip,
  v2ray-domain-list-community,
  sub-store,
  sub-store-frontend,
  mihomo,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
}:

let
  sparkle-service = buildGoModule {
    pname = "sparkle-service";
    version = "0-unstable-2025-10-24";

    src = fetchFromGitHub {
      owner = "xishang0128";
      repo = "sparkle-service";
      rev = "fb7006438d6335c7ee9fbf4530b1821428385cab";
      hash = "sha256-V1HwYbdUunLTWFhfW7EHDDkIQyKFq2mbUysndttIlTE=";
    };

    vendorHash = "sha256-1n4CJT7zh6uxg6fGAVQz/KVKqXelFoTtETFPARcbPb8=";

    meta.mainProgram = "sparkle-service";
  };
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sparkle";
  version = "1.26.2";

  src = fetchFromGitHub {
    owner = "xishang0128";
    repo = "sparkle";
    tag = finalAttrs.version;
    hash = "sha256-6/VdWVobiBjjggC215g/zZmVAx1EzGbPE6+xp6ekcJw=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-P0KwmLwj1FIWBduT2DzOaRCYrbQ+kvcCdCgabAhmMm8=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
    copyDesktopItems
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
  };

  # workaround for https://github.com/electron/electron/issues/31121
  postPatch = ''
    sed -i "s#process\\.resourcesPath#'$out/lib/sparkle/resources'#g" \
      src/main/utils/dirs.ts
  '';

  buildPhase = ''
    runHook preBuild

    # electron.dist 只读，electron-builder 复制时保留了 mode/flags/ACL，导致目标也只读
    # 因此先复制一份到工作目录，修改权限后再传给 electron-builder
    ELECTRON_SRC="${electron.dist}"
    ELECTRON_DST="$PWD/.electron-dist"
    rm -rf "$ELECTRON_DST"
    mkdir -p "$ELECTRON_DST"
    ditto "$ELECTRON_SRC/Electron.app" "$ELECTRON_DST/Electron.app"
    chmod -R u+rwX "$ELECTRON_DST"
    chflags -R nouchg,noschg "$ELECTRON_DST" 2>/dev/null || true

    npm exec electron-vite -- build
    npm exec electron-builder -- \
      --dir \
      --publish never --mac \
      -c.electronDist="$ELECTRON_DST" \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    mkdir -p $out/lib/sparkle
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/lib/sparkle/

    install -D resources/icon.png $out/share/icons/hicolor/512x512/apps/sparkle.png

    export resourceDir="$out/lib/sparkle/resources"
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    appPath="$(find dist -maxdepth 2 -name 'Sparkle.app' -print -quit)"
    if [ -z "$appPath" ]; then
      echo "error: Sparkle.app not found under dist/" >&2
      find dist -maxdepth 2 -print >&2 || true
      exit 1
    fi
    echo $appPath

    mkdir -p "$out/Applications"
    cp -r "$appPath" "$out/Applications/Sparkle.app"
    chmod -R u+w "$out/Applications/Sparkle.app"

    export resourceDir="$out/Applications/Sparkle.app/Contents/Resources"
  ''
  + ''
    mkdir -p "$resourceDir"/{files,sidecar}
    ln -s ${sub-store-frontend} "$resourceDir/files/sub-store-frontend"
    ln -s ${sub-store}/share/sub-store/sub-store.bundle.js "$resourceDir/files/sub-store.bundle.js"
    ln -s ${dbip-asn-lite.mmdb} "$resourceDir/files/ASN.mmdb"
    ln -s ${dbip-country-lite.mmdb} "$resourceDir/files/country.mmdb"
    ln -s ${v2ray-geoip}/share/v2ray/geoip.dat "$resourceDir/files/geoip.dat"
    ln -s ${v2ray-domain-list-community}/share/v2ray/geosite.dat "$resourceDir/files/geosite.dat"
    ln -s ${lib.getExe sparkle-service} "$resourceDir/files/sparkle-service"
    ln -s ${lib.getExe mihomo} "$resourceDir/sidecar/mihomo"
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    makeWrapper '${lib.getExe electron}' $out/bin/sparkle \
      --add-flags "$resourceDir/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    appExe="$(find "$out/Applications/Sparkle.app/Contents/MacOS" -maxdepth 1 -type f -perm -111 -print -quit)"
    if [ -z "$appExe" ]; then
      echo "error: no executable found under Sparkle.app/Contents/MacOS" >&2
      find "$out/Applications/Sparkle.app/Contents/MacOS" -maxdepth 1 -print >&2 || true
      exit 1
    fi

    makeWrapper "$appExe" $out/bin/sparkle \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "sparkle";
      desktopName = "Sparkle";
      exec = "sparkle %U";
      terminal = false;
      type = "Application";
      icon = "sparkle";
      startupWMClass = "sparkle";
      comment = "Another Mihomo GUI";
      categories = [
        "Utility"
        "Network"
      ];
      mimeTypes = [
        "x-scheme-handler/clash"
        "x-scheme-handler/mihomo"
        "x-scheme-handler/sparkle"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Another Mihomo GUI";
    homepage = "https://github.com/xishang0128/sparkle";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sparkle";
    maintainers = [ ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
})
