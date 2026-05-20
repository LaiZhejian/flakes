{
  rustPlatform,
  fetchFromGitHub,
  meta,
  procps,
  lib,
  stdenv,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clash-verge-service-ipc";
  version = "2.0.21";

  src = fetchFromGitHub {
    owner = "clash-verge-rev";
    repo = "clash-verge-service-ipc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9c9fM1l31NbY//Ri50Ql60BWWgISjMWj72ABixRaXvM=";
  };

  postPatch =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      # set socket path for service and test respectively
      substituteInPlace src/lib.rs \
        --replace-fail "/tmp/verge/clash-verge-service.sock" "/run/clash-verge-rev/service.sock" \
        --replace-fail "/tmp/verge/clash-verge-service-test.sock" "$sourceRoot/clash-verge-service-test.sock"
      substituteInPlace tests/test_start_permissions.rs \
        --replace-fail "owner_perm | group_perm | other_perm" "0o0755"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # set socket path for service and test respectively
      substituteInPlace src/lib.rs \
        --replace-fail "/tmp/verge/clash-verge-service-test.sock" "$sourceRoot/clash-verge-service-test.sock"
    '';

  cargoHash = "sha256-UbNN3uFu5anQV+3KMFPNnGrCDQTGb4uC9K83YghfQgY=";

  buildFeatures = [
    "standalone"
  ];

  nativeCheckInputs = [
    procps
  ];
  # build mock_binary for tests
  preCheck = ''
    cargo build --features=test
  '';
  doCheck = false;
  checkFeatures = [
    "standalone"
    "test"
    "client"
  ];
  inherit meta;
})
