{
  nixConfig.allow-import-from-derivation = true;

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    publetry.url = "git+https://github.com/Blue-Berry/publetry.git?lfs=1";
  };

  outputs =
    {
      nixpkgs,
      disko,
      publetry,
      ...
    }:
    {
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit publetry;
        };
        modules = [
          disko.nixosModules.disko
          ./hardware-configuration.nix
          ./disk-config.nix
          ./configuration.nix
        ];
      };
    };
}
