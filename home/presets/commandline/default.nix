{ pkgs, ... }:

{
  imports = [
    ../../modules/commandline/git
    ../../modules/commandline/ssh
    ../../modules/commandline/bash
    ../../modules/commandline/zsh
    ../../modules/commandline/fish
    ../../modules/commandline/starship # shell prompt 

    ../../modules/commandline/eza # ll
    ../../modules/commandline/bat # cat
    ../../modules/commandline/bottom # top
    ../../modules/commandline/zoxide # cd
    ../../modules/commandline/fd # find filename
    ../../modules/commandline/fzf # file preview
    ../../modules/commandline/gitui
    ../../modules/commandline/tealdeer # tldr
    ../../modules/commandline/atuin # history
    ../../modules/commandline/yazi # file broswer

    ../../modules/commandline/uv
    ../../modules/commandline/direnv
    ../../modules/commandline/neovim # editor
    # ../../modules/commandline/rclone
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

    du-dust # du extended
    ripgrep # (rg) find content
    jq # json preview
    sd # regex
    tokei # tokens statistic
    difftastic # diff extended

    tmux
  ];
}
