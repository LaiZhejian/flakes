{
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.sshKeyPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
    defaultSopsFile = ./secrets.yaml;
  };
}
