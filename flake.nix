{
  description = "Prometheus and Grafana for internal use";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # SOPS Nix
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      tc2 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };

    packages.x86_64-linux.renovate = nixpkgs.legacyPackages.x86_64-linux.callPackage ./renovate/package.nix {};
  };
}
