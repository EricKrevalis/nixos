{ rustPlatform }:

# sway autotiler, source in ./src
rustPlatform.buildRustPackage {
  pname = "sway-autotile";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
