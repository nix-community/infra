# https://github.com/helsinki-systems/nixos-infra/blob/972b2233c8748133c05372783d551d2494152771/non-critical-infra/packages/hydra-queue-runner/default.nix
{
  rustPlatform,
  pkg-config,
  openssl,
  zlib,
  protobuf,
  lib,
  makeWrapper,
  nixVersions,
  nlohmann_json,
  libsodium,
  boost,
  withOtel ? false,
  withTokioConsole ? false,
  inputs,
}:
let
  nix' = nixVersions.nix_2_31;
  src = inputs.hydra-queue-runner;
  cargoLock.lockFile = "${src}/Cargo.lock";
  cargoLock.outputHashes = {
    "nix-diff-0.1.0" = "sha256-heUqcAnGmMogyVXskXc4FMORb8ZaK6vUX+mMOpbfSUw=";
  };
  nativeBuildInputs = [
    pkg-config
    protobuf
    makeWrapper
  ];
  buildInputs = [
    openssl
    zlib
    protobuf

    nix'
    nlohmann_json
    libsodium
    boost
  ];
  meta = {
    description = "Hydra Queue-Runner implemented in rust";
    homepage = "https://github.com/helsinki-systems/hydra-queue-runner";
    license = [ lib.licenses.gpl3 ];
    maintainers = [ lib.maintainers.conni2461 ];
    platforms = lib.platforms.all;
  };
in
{
  runner = rustPlatform.buildRustPackage {
    name = "hydra-queue-runner";
    inherit src;
    __structuredAttrs = true;
    strictDeps = true;

    inherit
      cargoLock
      nativeBuildInputs
      buildInputs
      ;

    buildAndTestSubdir = "queue-runner";
    buildFeatures = lib.optional withOtel "otel" ++ lib.optional withTokioConsole "tokio-console";

    postInstall = ''
      wrapProgram $out/bin/queue-runner \
        --prefix PATH : ${lib.makeBinPath [ nix' ]} \
        --set-default JEMALLOC_SYS_WITH_MALLOC_CONF "background_thread:true,narenas:1,tcache:false,dirty_decay_ms:0,muzzy_decay_ms:0,abort_conf:true"
    '';

    meta = meta // {
      mainProgram = "queue-runner";
    };
  };

  builder = rustPlatform.buildRustPackage {
    name = "hydra-queue-builder";
    inherit src;
    __structuredAttrs = true;
    strictDeps = true;

    inherit
      cargoLock
      nativeBuildInputs
      buildInputs
      ;

    buildAndTestSubdir = "builder";

    postInstall = ''
      wrapProgram $out/bin/builder \
        --prefix PATH : ${lib.makeBinPath [ nix' ]} \
        --set-default JEMALLOC_SYS_WITH_MALLOC_CONF "background_thread:true,narenas:1,tcache:false,dirty_decay_ms:0,muzzy_decay_ms:0,abort_conf:true"
    '';

    meta = meta // {
      mainProgram = "builder";
    };
  };
}
