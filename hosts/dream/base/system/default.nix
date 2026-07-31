{
  inputs,
  lib,
  pkgs,
  hostMeta,
  ...
}:

let
  sshPublicKeys = import ../ssh-public-keys.nix;
in
{
  custom.system.profiles.minimal.enable = true;
  custom.system.stacks.homebrew.enable = true;

  # Preserve pre-Nix files the first time Home Manager takes ownership.
  home-manager.backupFileExtension = "hm-backup";

  custom.system.users.${hostMeta.username} = {
    name = hostMeta.username;
    authorizedKeys = [
      sshPublicKeys.idRsa
    ];
  };
  users.users.${hostMeta.username}.shell = pkgs.fish;

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
  homebrew.casks = lib.mkForce ([
    "1password-cli"
    "alfred"
    "iterm2"
    "keyboardcleantool"
    "surge"
    "visual-studio-code"
    "zotero"
  ]);

  # Allow sudo authentication with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  time.timeZone = "Asia/Shanghai";

  # Keep this desktop Mac available for long-running jobs while on AC power.
  system.activationScripts.postActivation.text = ''
    pmset -a \
      displaysleep 0 \
      sleep 0 \
      disksleep 10 \
      powernap 1 \
      womp 1 \
      tcpkeepalive 1 \
      ttyskeepawake 1

    # nix-darwin does not update Directory Service for pre-existing users that
    # are intentionally absent from users.knownUsers. Keep their login shell
    # aligned with this configuration without attempting to recreate them.
    if /usr/bin/dscl . -read "/Users/${hostMeta.username}" >/dev/null 2>&1; then
      current_shell=$(/usr/bin/dscl . -read "/Users/${hostMeta.username}" UserShell \
        | /usr/bin/awk '{ print $2 }')
      if [ "$current_shell" != "/run/current-system/sw/bin/fish" ]; then
        /usr/bin/dscl . -create "/Users/${hostMeta.username}" UserShell \
          /run/current-system/sw/bin/fish
      fi
    fi
  '';

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
