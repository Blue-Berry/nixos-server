{
  nixConfig.allow-import-from-derivation = true;

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    publetry.url = "git+https://github.com/Blue-Berry/publetry.git?lfs=1";
    bmpFromTxt.url = "github:Blue-Berry/bmp-from-txt";
    # erratique.ch is a single personal server (dumb-HTTP git) that GitHub
    # Actions runners cannot reliably reach, causing "Failed to fetch git
    # repository" in CI. Redirect these transitive sources to their GitHub
    # mirrors, which build identically and fetch reliably.
    bmpFromTxt.inputs.bytesrw-src.url = "github:dbuenzli/bytesrw";
    bmpFromTxt.inputs.webs-src.url = "github:dbuenzli/webs";
  };

  outputs =
    {
      nixpkgs,
      disko,
      publetry,
      bmpFromTxt,
      ...
    }:
    {
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit publetry bmpFromTxt;
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
