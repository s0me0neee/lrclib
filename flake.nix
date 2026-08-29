{
  description = "lrclib dev shell — the native build deps reqwest's TLS backend pulls in";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            pkg-config
            cmake # aws-lc-sys (reqwest 0.13's TLS backend) builds AWS-LC's C sources
          ] ++ pkgs.lib.optionals pkgs.stdenv.isx86_64 [
            nasm # aws-lc-sys/ring's hand-optimised asm on x86_64
          ];

          buildInputs = with pkgs; [
            openssl # native-tls's Linux backend (openssl-sys is in Cargo.lock)
          ];

          shellHook = ''
            echo "lrclib dev shell — rustc $(rustc --version 2>/dev/null || echo '?')"
          '';
        };
      });
}
