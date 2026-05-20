{
  description = "Undefined01's everything about Nix, e.g., NixOS Configuration, customized packages, etc.";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable?shallow=1";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable?shallow=1";
    };
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager/master?shallow=1";
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

    # utils
    flake-compat = {
      url = "github:NixOS/flake-compat?shallow=1";
      flake = false;
    };
    nur = {
      url = "github:nix-community/NUR?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix for darwin
    darwin = {
      url = "github:LnL7/nix-darwin?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew?shallow=1";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle?shallow=1";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core?shallow=1";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask?shallow=1";
      flake = false;
    };

    # nix for wsl
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;

      lib = nixpkgs.lib.extend (final: prev: { custom = import ./lib { inherit (nixpkgs) lib; }; });

      forAllSystems = lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      defaultSystemSpecifier = {
        isLinux = false;
        isWsl = false;
        isDarwin = false;
      };
      buildSystemFromPath =
        {
          builder,
          path,
          specialArgs ? { },
        }:
        builtins.listToAttrs (
          map (host: {
            name = lib.removeSuffix ".nix" host;
            value = builder {
              specialArgs = {
                inherit inputs outputs lib;
              }
              // specialArgs;
              modules = [ (lib.path.append path host) ];
            };
          }) (builtins.attrNames (builtins.readDir path))
        );
      nixos = buildSystemFromPath {
        builder = lib.nixosSystem;
        path = ./system/top/nixos;
        specialArgs = defaultSystemSpecifier // {
          isLinux = true;
        };
      };
      wsl = buildSystemFromPath {
        builder = lib.nixosSystem;
        path = ./system/top/wsl;
        specialArgs = defaultSystemSpecifier // {
          isLinux = true;
          isWsl = true;
        };
      };
      darwin = buildSystemFromPath {
        builder = inputs.darwin.lib.darwinSystem;
        path = ./system/top/darwin;
        specialArgs = defaultSystemSpecifier // {
          isDarwin = true;
        };
      };

      home = lib.custom.callDirectoryRecursive {
        callFunc =
          host:
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = {
              user = "dream";
              inherit inputs outputs;
            };
            modules = [ host ];
          };
        directory = ./home/top;
      };

      # getSystemPackages =
      #   attr:
      #   if attr ? config then
      #     (attr.config.environment.systemPackages)
      #     ++ (lib.flatten (
      #       map (config: config.home.packages) (builtins.attrValues attr.config.home-manager.users)
      #     ))
      #   else
      #     lib.flatten (map getSystemPackages (builtins.attrValues attr));
      packagesToAttrset =
        list:
        builtins.listToAttrs (
          map (p: {
            name = p.name;
            value = p;
          }) list
        );
      getSystemPackages =
        attr:
        if attr ? config then
          {
            system = packagesToAttrset attr.config.environment.systemPackages;
            home = builtins.mapAttrs (
              name: value: packagesToAttrset value.home.packages
            ) attr.config.home-manager.users;
          }
        else
          builtins.mapAttrs (name: value: getSystemPackages value) attr;
      flatMapRecursive =
        cond: f: path: attr:
        if cond attr then
          lib.concatMapAttrs (name: value: flatMapRecursive cond f (path ++ [ name ]) value) attr
        else
          f path attr;
      flattenHierarchy =
        let
          isLeaf = attr: attr |> builtins.attrValues |> builtins.any (p: p ? type && p.type == "derivation");
          flattenHierarchy_ =
            prefix: attr:
            if isLeaf attr then
              [
                {
                  name = builtins.substring 1 (builtins.stringLength prefix) prefix;
                  value = attr;
                }
              ]
            else
              attr
              |> lib.attrsToList
              |> map ({ name, value }: flattenHierarchy_ "${prefix}-${name}" value)
              |> lib.flatten;
        in
        attr: flattenHierarchy_ "" attr |> builtins.listToAttrs;
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

      nixosConfigurations = nixos // wsl;
      darwinConfigurations = darwin;
      homeConfigurations = home;

      checks = {
        x86_64-linux = {
          packages =
            outputs.nixosConfigurations
            |> flatMapRecursive (as: !(as ? config)) (path: value: {
              "${lib.concatStringsSep "-" path}" = getSystemPackages value;
            }) [ ];
          configurations =
            (
              outputs.nixosConfigurations
              |> flatMapRecursive (as: !(as ? config)) (path: value: {
                "${lib.concatStringsSep "-" path}" = value.config.system.build.toplevel;
              }) [ "system" ]
            )
            // (
              outputs.homeConfigurations.docker
              |>
                flatMapRecursive (as: !(as ? config))
                  (path: value: { "${lib.concatStringsSep "-" path}" = value.activationPackage; })
                  [
                    "home"
                    "docker"
                  ]
            );
        };
        aarch64-darwin = {
          packages =
            outputs.darwinConfigurations
            |> flatMapRecursive (as: !(as ? config)) (path: value: {
              "${lib.concatStringsSep "-" path}" = getSystemPackages value;
            }) [ ];
          configurations =
            outputs.darwinConfigurations
            |> flatMapRecursive (as: !(as ? config)) (path: value: {
              "${lib.concatStringsSep "-" path}" = value.system;
            }) [ "system" ];
        };
      };
    };
}
