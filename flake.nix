{
  description = "Undefined01's everything about Nix, e.g., NixOS Configuration, customized packages, etc.";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mutable-home-files = {
      url = "github:Undefined01/mutable-home-files";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # utils
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zsh-autosuggestions = {
      url = "github:zsh-users/zsh-autosuggestions/85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5";
      flake = false;
    };
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting/5eb677bb0fa9a3e60f0eff031dc13926e093df92";
      flake = false;
    };
    zsh-cmdtime = {
      url = "github:tom-auger/cmdtime/ffc72641dcfa0ee6666ceb1dc712b61be30a1e8b";
      flake = false;
    };
    zsh-fzf-tab = {
      url = "github:Aloxaf/fzf-tab/fac145167f7ec1861233c54de0c8900b09c650fe";
      flake = false;
    };
    zsh-fzf-ls = {
      url = "github:ezh/fzf-ls/956de07f1f3f14f825cc8feb8d7491ef01edcac1";
      flake = false;
    };

    # nix for darwin
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # nix for wsl
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib.extend (final: prev: { custom = import ./lib { inherit (nixpkgs) lib; }; });

      forAllSystems = lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      hosts = import ./hosts { inherit inputs lib; };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
          };
        in
        lib.packagesFromDirectoryRecursive {
          callPackage = lib.callPackageWith pkgs;
          directory = ./pkgs;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
          };
        in
        lib.packagesFromDirectoryRecursive {
          callPackage = lib.callPackageWith pkgs;
          directory = ./shell;
        }
      );

      overlays = import ./overlays { inherit inputs; };

      inherit (hosts) nixosConfigurations darwinConfigurations homeConfigurations;
    };
}
