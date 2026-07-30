{
  config,
  hostMeta,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  sshPublicKeys = import ./ssh-public-keys.nix;
  vscodeCliOnly =
    pkgs.runCommand "vscode-cli-${pkgs.vscode.version}"
      {
        pname = "vscode-cli";
        inherit (pkgs.vscode) version;
        meta.mainProgram = "code";
      }
      ''
        mkdir -p "$out/bin"
        ln -s ${lib.getExe pkgs.vscode} "$out/bin/code"
      '';
in
{
  imports = [
    ./alfred
    ./darwin-preferences.nix
    ./secrets
    ./zotero
  ];

  # Keep all owner-specific state in this host. Shared modules under home/
  # provide options and defaults, but do not need to know who uses them.
  home.username = lib.mkDefault hostMeta.username;
  home.homeDirectory = lib.mkDefault "/Users/${hostMeta.username}";

  # ---- profiles ----
  custom.home.profiles.commandline.enable = true;
  custom.home.profiles.darwin.enable = true;
  custom.home.profiles.darwin.packages = lib.mkForce [ ];

  # ---- desktop applications ----
  custom.home.stacks.desktop.aerospace.enable = lib.mkForce false;
  custom.home.stacks.desktop.wezterm.enable = lib.mkForce false;
  custom.home.stacks.desktop.firefox.enable = lib.mkForce false;
  custom.home.stacks.desktop.thunderbird.enable = lib.mkForce false;
  # VS Code settings and extensions are synchronized through its GitHub
  # account. Keep only the CLI available through Home Manager.
  custom.home.stacks.desktop.vscode.enable = lib.mkForce false;
  custom.home.stacks.desktop.zotero.enable = lib.mkForce false;

  # ---- commandline tools ----
  custom.home.stacks.commandline.editor.variant = lib.mkForce "none"; # 关闭nvim
  custom.home.stacks.commandline.editor.lsp.enable = lib.mkForce false;
  custom.home.stacks.commandline.git.ui = lib.mkForce "gitui";
  custom.home.stacks.commandline.shell.starship.enable = lib.mkForce true;
  custom.home.stacks.commandline.rclone.enable = lib.mkForce false;
  custom.home.stacks.commandline.claudecode.enable = lib.mkForce false;
  # Codex keeps its account and application configuration in local OpenAI
  # account state; flakes only installs the package below.
  custom.home.stacks.commandline.codex.enable = lib.mkForce false;

  # ---- cli packages: replace zellij+osc with tmux ----
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

  # ---- zsh: oh-my-zsh + plugins + init.zsh ----
  programs.zsh = {
    enable = lib.mkForce true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "cmdtime"
        "fzf-tab"
        "fzf-ls"
      ];
      theme = "robbyrussell";
      extraConfig = "ZSH_CUSTOM=\"${config.home.homeDirectory}/.local/zsh_plugins\"";
    };
    initContent = lib.mkForce (
      ''
        # Oh-my-zsh
        if [[ -n "$ZSH" ]] && [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
          export ZSH_CUSTOM="${config.home.homeDirectory}/.local/zsh_plugins"
          plugins=(zsh-autosuggestions zsh-syntax-highlighting cmdtime fzf-tab fzf-ls)
          source "$ZSH/oh-my-zsh.sh"
        fi
        [[ -r "${config.home.homeDirectory}/.config/secrets/zotero/api.sh" ]] && \
          source "${config.home.homeDirectory}/.config/secrets/zotero/api.sh"
      ''
      + builtins.readFile ./init.zsh
    );
  };

  home.file.".local/zsh_plugins/plugins/cmdtime".source = inputs.zsh-cmdtime;
  home.file.".local/zsh_plugins/plugins/fzf-ls".source = inputs.zsh-fzf-ls;
  home.file.".local/zsh_plugins/plugins/fzf-tab".source = inputs.zsh-fzf-tab;
  home.file.".local/zsh_plugins/plugins/zsh-autosuggestions".source = inputs.zsh-autosuggestions;
  home.file.".local/zsh_plugins/plugins/zsh-syntax-highlighting".source =
    inputs.zsh-syntax-highlighting;

  home.file.".ssh/config.d/config" = {
    source = ./ssh-config;
  };
  home.file.".ssh/id_rsa.pub".text = "${sshPublicKeys.idRsa}\n";
  home.file.".ssh/exp_server.pub".text = "${sshPublicKeys.expServer}\n";

  home.file."Library/Application Support/iTerm2/DynamicProfiles/dream.json" = {
    text = lib.replaceStrings [ "/Users/dream" ] [ config.home.homeDirectory ] (
      builtins.readFile ./iterm2-profile.json
    );
  };

  # ---- fish: shellInit ----
  programs.fish = {
    enable = lib.mkForce true;
    shellInit = builtins.readFile ./init.fish + ''

      if test -r "${config.home.homeDirectory}/.config/secrets/zotero/api.fish"
        source "${config.home.homeDirectory}/.config/secrets/zotero/api.fish"
      end
    '';
  };

  # ---- ssh: remove keepalive, only github.com ----
  programs.ssh = {
    enable = lib.mkForce true;
    settings = lib.mkForce {
      "github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };

  # ---- uv: link-mode clone, no python-downloads ----
  programs.uv = {
    enable = lib.mkForce true;
    settings = lib.mkForce {
      pip.index-url = "https://pypi.mirrors.ustc.edu.cn/simple/";
      index = [
        {
          url = "https://pypi.mirrors.ustc.edu.cn/simple/";
          default = true;
        }
      ];
      pip.link-mode = "clone";
      python-install-mirror = "https://hub.gitmirror.com/https://github.com/astral-sh/python-build-standalone/releases/download";
    };
  };

  home.shellAliases = {
    python = "uv run python";
  };

  # ---- git: user info + safe.directory ----
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
    safe.directory = "*";
  };

  programs.git.signing.signByDefault = lib.mkForce false;

  # ---- extra packages ----
  home.packages = with pkgs; [
    claude-code
    codex
    kubectl
    vscodeCliOnly
  ];
}
