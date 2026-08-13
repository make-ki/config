{
  description = "Stark's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/867dcbc30bafe3c862ef88620f2e7a109d7d3be5";
    # Home-manager manages user-level configs (tmux, nvim, hyprland, ...).
    # `follows = "nixpkgs"` makes it use the SAME nixpkgs as the system,
    # so we don't build two copies of everything.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixos/default.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
