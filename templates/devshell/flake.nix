{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      # uncomment what fits
      # packages is just a list, mix languages if needed
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          # python
          # (pkgs.python3.withPackages (ps: with ps; [ numpy pandas requests ]))

          # node
          # pkgs.nodejs

          # rust
          # pkgs.cargo
          # pkgs.rustc

          # go
          # pkgs.go
        ];
      };
    };
}
