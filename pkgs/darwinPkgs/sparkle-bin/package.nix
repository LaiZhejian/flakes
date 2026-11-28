{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libGL,
  libgbm,
  libxkbcommon,
  musl,
  nspr,
  nss,
  pango,
  udev,
  xorg,
  p7zip,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libarchive,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sparkle";
  version = "1.26.10";

  src =
    let
      selectSystem =
        attrs:
        attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      asset = selectSystem {
        x86_64-linux = "sparkle-linux-${finalAttrs.version}-amd64.deb";
        aarch64-linux = "sparkle-linux-${finalAttrs.version}-arm64.deb";
        x86_64-darwin = "sparkle-macos-${finalAttrs.version}-x64.pkg";
        aarch64-darwin = "sparkle-macos-${finalAttrs.version}-arm64.pkg";
      };
    in
    fetchurl {
      url = "https://github.com/xishang0128/sparkle/releases/download/${finalAttrs.version}/${asset}";
      hash = selectSystem {
        x86_64-linux = "sha256-4xfv+As2pO5Z12kGhBXVBuCXYL/7oYq2kNbPYh+BjJg=";
        aarch64-linux = "sha256-ZvLnbdse+aOyBe6FYd90Y1RXy7NqeyKiPE0UrSuipu4=";
        x86_64-darwin = "sha256-gKXy6V9AfQgZOXj05ja5KB8aLGlf3c14akyn5g3VQxE=";
        aarch64-darwin = "sha256-T85OoHPy7gMghHUSRg8yX300XkIAmrsVbyGYa313Vbo=";
      };
    };

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
      dpkg
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libarchive
      p7zip
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libGL
    libgbm
    libxkbcommon
    musl
    nspr
    nss
    pango
    udev
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    (lib.getLib stdenv.cc.cc)
  ];

  unpackPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preUnpack

    7z x $src
    bsdtar -xf Payload~

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/bin
    cp -r opt $out/opt
    substituteInPlace usr/share/applications/sparkle.desktop \
      --replace-fail "/opt/sparkle/sparkle" "sparkle"
    cp -r usr/share $out/share
    ln -s $out/opt/sparkle/sparkle $out/bin/sparkle
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r Sparkle.app $out/Applications/
  ''
  + ''
    runHook postInstall
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-needed libGL.so.1 $out/opt/sparkle/sparkle
  '';

  passthru.updateScript = ./update.sh;

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
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
