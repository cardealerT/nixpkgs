{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cmake,
  gtest,
  jre,
  pkg-config,
  boost,
  icu,
  protobuf,
  Foundation,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libphonenumber";
  version = "9.0.3";

  src = fetchFromGitHub {
    owner = "google";
    repo = "libphonenumber";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5sstZ9wxZrZPMCN4/KAXWFDXdFSsF2FL7aSsLn3wJ1I=";
  };

  patches = [
    # An earlier version of this patch was submitted upstream but did not get
    # any interest there - https://github.com/google/libphonenumber/pull/2921
    ./build-reproducibility.patch
  ];

  nativeBuildInputs = [
    cmake
    gtest
    jre
    pkg-config
  ];

  buildInputs =
    [
      boost
      icu
      protobuf
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      Foundation
    ];

  cmakeDir = "../cpp";

  doCheck = true;

  checkTarget = "tests";

  cmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    (lib.cmakeFeature "CMAKE_CROSSCOMPILING_EMULATOR" (stdenv.hostPlatform.emulator buildPackages))
    (lib.cmakeFeature "PROTOC_BIN" (lib.getExe buildPackages.protobuf))
  ];

  meta = with lib; {
    changelog = "https://github.com/google/libphonenumber/blob/${finalAttrs.src.rev}/release_notes.txt";
    description = "Google's i18n library for parsing and using phone numbers";
    homepage = "https://github.com/google/libphonenumber";
    license = licenses.asl20;
    maintainers = with maintainers; [ illegalprime ];
  };
})
