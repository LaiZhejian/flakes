{ inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment = {
    persistence."/nix/persist" = {
      directories = [
        # "/etc/nixos" # bind mounted from /nix/persist/etc/nixos to /etc/nixos
        "/etc/NetworkManager/system-connections"
        "/var/log"
        "/var/lib"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
