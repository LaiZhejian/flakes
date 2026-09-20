{
  config,
  hostMeta,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  # Dream-owned container configuration; deliberately independent of Darwin imports.
  home.username = hostMeta.username;
  home.homeDirectory =
    if hostMeta.username == "root" then "/root" else "/home/${hostMeta.username}";
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
  home.sessionVariables = lib.optionalAttrs (hostMeta.username == "root") {
    NIX_REMOTE = "local";
  };

  programs.home-manager.enable = true;
  nix = {
    enable = true;
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };

  custom.home.profiles.commandline.enable = true;
  custom.home.stacks.commandline = {
    editor.variant = lib.mkForce "none";
    editor.lsp.enable = lib.mkForce false;
    git.ui = lib.mkForce "gitui";
    ssh.enable = lib.mkForce false;
    gpgAgent.enable = lib.mkForce false;
    rclone.enable = lib.mkForce false;
    claudecode.enable = lib.mkForce false;
    codex.enable = lib.mkForce false;
    shell.starship.enable = true;
    # Keep interactive zsh in zsh rather than auto-entering fish.
    shell.fish.enable = lib.mkForce false;
  };
  custom.home.stacks.desktop.vscode.enable = lib.mkForce false;

  custom.home.profiles.commandline.packages = lib.mkForce (
    with pkgs;
    [
      wget
      curl
      less
      man
      file
      zip
      unzip
      p7zip
      zstd
      vim

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
    ]
  );

  home.packages = with pkgs; [
    codex
    kubectl
  ];

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      custom = "${config.home.homeDirectory}/.local/zsh_plugins";
      plugins = [
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "cmdtime"
        "fzf-tab"
        "fzf-ls"
      ];
    };
    # The shared zsh module enables extended, incremental timed history.
  };
  home.file.".local/zsh_plugins/plugins/cmdtime".source = inputs.zsh-cmdtime;
  home.file.".local/zsh_plugins/plugins/fzf-ls".source = inputs.zsh-fzf-ls;
  home.file.".local/zsh_plugins/plugins/fzf-tab".source = inputs.zsh-fzf-tab;
  home.file.".local/zsh_plugins/plugins/zsh-autosuggestions".source = inputs.zsh-autosuggestions;
  home.file.".local/zsh_plugins/plugins/zsh-syntax-highlighting".source = inputs.zsh-syntax-highlighting;

  programs.uv.settings = lib.mkForce {
    pip.index-url = "https://bytedpypi.byted.org/simple/";
    index = [
      {
        url = "https://bytedpypi.byted.org/simple/";
        default = true;
      }
    ];
    pip.link-mode = "clone";
    python-downloads = "manual";
  };

  programs.git.settings = lib.mkForce {
    user.name = "Jackie_Lai";
    user.email = "742949301@qq.com";
    alias = {
      graph = "log --all --decorate --oneline --graph";
      lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
      root = "rev-parse --show-toplevel";
    };
    init.defaultBranch = "main";
    core.autocrlf = "input";
    core.quotePath = false;
    pull.rebase = false;
    push.autoSetupRemote = true;
    merge.conflictStyle = "zdiff3";
    rebase.autostash = true;
    log.date = "iso";
    column.ui = "auto";
    branch.sort = "committerdate";
  };

  programs.git.signing.signByDefault = lib.mkForce false;
}
