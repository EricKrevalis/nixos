{
  description = "NixOS configuration for desktop and laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, stylix, ... }:
    let
      lib = nixpkgs.lib;

      # shared by every host, per-host blocks override these
      common = {
        username = "eric";
        timezone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        gitName = "EricKrevalis";
        gitEmail = "eric.krevalis@gmail.com";
        # "<host>" = "<key filename in ~/.ssh>", per-host blocks can extend this
        sshIdentities = {
          "github.com" = "id_ed25519_github";
        };
        gaming = false; # steam, gamescope, gamemode, vesktop
        work = false; # eduvpn client for the institutional wireguard vpn, teams
        nvidia = false; # the proprietary nvidia gpu stack
        arkenfox = false; # arkenfox-hardened firefox, needs manual uBlock and exception upkeep
      };

      # one mkHost call per machine, settings is common merged with per-host overrides,
      # threaded to every module via specialArgs.
      mkHost = settings: lib.nixosSystem {
        system = settings.system or "x86_64-linux";
        specialArgs = { inherit settings; };
        modules = [
          ./modules
          ./hosts/${settings.hostname}/configuration.nix
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit settings; };
            home-manager.users.${settings.username}.imports = [
              ./home
              ./hosts/${settings.hostname}/home.nix
            ];
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        desktop = mkHost (common // {
          hostname = "desktop";
          nvidia = true; # RTX 3060 Ti
          gaming = true;
          work = true;
          arkenfox = true;
          sshIdentities = common.sshIdentities // {
            "git.haw-hamburg.de" = "id_ed25519_haw";
          };
        });

        # laptop out until hosts/laptop/hardware-configuration.nix exists, the placeholder breaks flake check.
        # re-enable the line below then.
        # laptop = mkHost (common // { hostname = "laptop"; });

        # starter host for a fork, uncomment after generating hosts/nixos/hardware-configuration.nix
        # nixos = mkHost (common // { hostname = "nixos"; });
      };

      # starter for a fork, copy this repo with:
      #   nix flake init -t github:EricKrevalis/nixos
      # the template is this whole repo: delete hosts/desktop and hosts/laptop,
      # set your values in common above, then start from the nixos host entry.
      templates.default = {
        path = ./.;
        description = "sway desktop flake, start from the hosts/nixos starter host";
      };
    };
}
