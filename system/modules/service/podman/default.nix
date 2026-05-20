{ pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune = {
      enable = true;
    };
  };

  environment.systemPackages = [
    pkgs.buildah
    pkgs.podman-compose
  ];
}
