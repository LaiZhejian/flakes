{
  description = "My Personal NixOS Configuration";

  nixConfig = {
    # substituters = "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/";
  };

  inputs =
    {
      # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
      nixpkgs.url = "github:nixos/nixpkgs/8068f3e8514b3a41be0f0d0a96783270bf38f98f";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      home-manager = {
        # url = "github:nix-community/home-manager/release-24.05";
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nix-vscode-extensions = {
        url = "github:nix-community/nix-vscode-extensions";
        inputs.nixpkgs.follows = "nixpkgs";
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
      homebrew-aerospace = {
        url = "github:nikitabobko/homebrew-aerospace";
        flake = false;
      };

      # nix for wsl
      nixos-wsl = {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      user = "dream";
      specialArgs = {
        inherit self inputs user;
      };

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      overlays = import ./overlays { inherit inputs; };
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );

      overlays = overlays;

      nixosConfigurations = {
        work = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./configurations/work
            ./modules/home-manager/nixos
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./configurations/wsl
            ./modules/home-manager/nixos
          ];
        };

        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./configurations/iso
            ./modules/home-manager/nixos
          ];
        };
      };

      darwinConfigurations = {
        darwin =
          let
            user = "dream";
          in
          inputs.darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = specialArgs // { inherit user; };
            modules = [
              ./configurations/darwin
              ./modules/home-manager/darwin
              ({
                home-manager.users.${user} = import ./home/darwin.nix;
              })
            ];
          };

        darwin-a = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = specialArgs;
          modules = [
            ./configurations/darwin/darwin-a.nix
            ./modules/home-manager/darwin
            ({
              home-manager.users.${user} = import ./home/darwin-a.nix;
            })
          ];
        };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.darwin.pkgs;

      homeConfigurations.dream = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = specialArgs // {isWsl=true;};
      };
    };
}
