{
  inputs,
  lib,
  pkgs,
  hostMeta,
  ...
}:

let
  isPersonalDarwin = hostMeta.username == "dream";
in
{
  custom.system.profiles.minimal.enable = true;
  custom.system.stacks.homebrew.enable = true;

  # Preserve pre-Nix files the first time Home Manager takes ownership.
  home-manager.backupFileExtension = "hm-backup";

  custom.system.users.${hostMeta.username} = {
    name = hostMeta.username;
    authorizedKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChzmtriHxELNCSVh+FTn/pWAbSwN99T2Ui/Fm0D8UEgnn1JDuwhKylDjlOJfeI62+PeYOucRKchz8TB5mGqj3yzpQqklyGEeWsnEno9JzgJEdSgXBJlndG05s0S9ugXH2ThedGPz1w6CKBe00rF36nNZErEN8Lrg9NVFbwYv5bHakWd4B+ACUMktUAYEVfWL8N+mLMiWMbNa5eW8pg/NE2m6b9D2zTedpiQtNaJfnxSH/GE/7ybfNTsa1Qe3iYFKi8IjHVmiJRrUyaoPFKBA5ltPLvHEkYmTIRHVJ4GZGVtQNfWycJcF0NHpYh3MVUaADvLJ3mlu+MNz2WON4dR3xbuk+Huv78CMo5VaDwmpUzmX2ctV9Zf//JJNtvjPJu4cs50YI3Td/8gSBhY1V7vV3tjfeIwBMr/77RhVyBvWO/y1y46ic8glOufC+L1FRCLBCPxN1Eq9UjuiXe2mb2GAt1ML2Je9DFXYv9LMxRQ0GPXc7Z3QfPCW21/lAG3eYQhRs= jackie_laichn@163.com"
    ];
    homeConfiguration = lib.mkDefault ./home.nix;
  };

  # ---- fonts: nerd-fonts fira-mono ----
  fonts.packages = lib.mkForce (
    with pkgs;
    [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.fira-mono
    ]
  );

  # ---- homebrew casks (replace upstream's) ----
  homebrew.casks = lib.mkForce (
    lib.optionals isPersonalDarwin [
      "1password-cli"
      "alfred"
      "iterm2"
      "keyboardcleantool"
      "surge"
    ]
  );

  # Allow sudo authentication with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  time.timeZone = "Asia/Shanghai";

  # nix integration for zsh and fish
  programs.zsh.enable = true;
  programs.fish.enable = true;
  environment.shells = with pkgs; [
    fish
    zsh
    bash
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    stateVersion = 5;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  };
}
