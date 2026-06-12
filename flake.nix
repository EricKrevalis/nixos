{
  description = "NixOS configuration for desktop and laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      # Every host wires in Home Manager the same way; only its own
      # configuration.nix differs.
      mkHost = configuration: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.eric = import ./home/home.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        desktop = mkHost ./hosts/desktop/configuration.nix;
        laptop = mkHost ./hosts/laptop/configuration.nix;
      };
    };
}
