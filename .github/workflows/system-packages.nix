let
  inherit (builtins)
    concatMap
    system
    attrValues
    mapAttrs
    currentSystem
    ;
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
  flake = builtins.getFlake ("path:" + toString ../..);
  packages =
    if currentSystem == "x86_64-linux" then
      flake.nixosConfigurations |> mapAttrs (_: cfg: getSystemPackages cfg)
    else if currentSystem == "aarch64-darwin" then
      flake.darwinConfigurations |> mapAttrs (_: cfg: getSystemPackages cfg)
    else
      { };
in
packages
