{
  inputs,
  pkgs,
  user,
  ...
}:

{
  imports = [ ./sops-nix ];

  nixpkgs.overlays = builtins.attrValues (import ../../../overlays { inherit inputs; });
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      unstable.to = {
        "type" = "github";
        "owner" = "NixOS";
        "repo" = "nixpkgs";
        "ref" = "nixos-unstable";
      };
      nur.flake = inputs.nur;
    };
  };

  home.sessionVariables = {
    PAGER = "less -FirSwX";
  };

  home.username = pkgs.lib.mkDefault user;
  home.homeDirectory = pkgs.lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}"
  );

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
