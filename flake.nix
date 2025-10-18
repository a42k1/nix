{

description = "first flake";

inputs = {
	nixpkgs.url = "nixpkgs/nixos-unstable";
	home-manager.url = "github:nix-community/home-manager/master";
	home-manager.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = { self, nixpkgs, home-manager, ...}:
	let
		lib = nixpkgs.lib;
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
	in {
		nixosConfigurations = {
			nix42 = lib.nixosSystem {
				inherit system;
				modules = [ ./configuration.nix ];
				};
		};
		homeConfigurations = {
			a42k1 = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
				modules = [ ./home.nix ];
				};
		};
	};
}