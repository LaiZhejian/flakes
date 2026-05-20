{ pkgs, inputs, ... }:

{
  imports = [
    inputs.mutable-home-files.homeManagerModules.default

    ../../modules/misc
    ../../modules/commandline/nix-index

    ../../modules/commandline/git
    ../../modules/commandline/ssh
    ../../modules/commandline/bash
    ../../modules/commandline/zsh
    ../../modules/commandline/fish
    ../../modules/commandline/starship # shell prompt

    ../../modules/commandline/eza
    ../../modules/commandline/bat
    ../../modules/commandline/ls-or-cat
    ../../modules/commandline/bottom
    ../../modules/commandline/zoxide
    ../../modules/commandline/fd
    ../../modules/commandline/fzf
    ../../modules/commandline/lazygit
    ../../modules/commandline/tealdeer
    ../../modules/commandline/atuin
    ../../modules/commandline/yazi

    ../../modules/commandline/uv
    ../../modules/commandline/direnv
    ../../modules/commandline/neovim
    ../../modules/commandline/rclone
    ../../modules/commandline/codex
    ../../modules/commandline/claudecode
  ];

  home.packages = with pkgs; [
    wget
    curl
    less
    man
    file
    zip
    unzip
    p7zip
    zstd

    gnupg
    openssl
    age

    dust
    ripgrep
    jq
    sd
    tokei
    difftastic

    tmux
  ];
}
