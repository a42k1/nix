{

	description = "first flake";

	inputs = {
 		nixpkgs.url = "nixpkgs/nixos-25.05";
		};

	outputs = { self, nixpkgs, ...}: #COLON?
		let
			lib = nixpkgs.lib;
		in {
		nixosConfigurations = {
			nix42 = lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./configuration.nix ];
			};
		};
	};
}
