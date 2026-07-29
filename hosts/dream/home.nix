{
  config,
  hostMeta,
  lib,
  pkgs,
  ...
}:

let
  isPersonalDarwin = hostMeta.username == "dream";
in
{
  imports = [
    ./darwin-preferences.nix
  ]
  ++ lib.optionals isPersonalDarwin [
    ./alfred
    ./secrets
  ];

  # Keep all owner-specific state in this host. Shared modules under home/
  # provide options and defaults, but do not need to know who uses them.
  home.username = lib.mkDefault hostMeta.username;
  home.homeDirectory = lib.mkDefault "/Users/${hostMeta.username}";

  # ---- profiles ----
  custom.home.profiles.commandline.enable = true;
  custom.home.profiles.darwin.enable = true;
  custom.home.profiles.darwin.packages = lib.mkForce (
    lib.optionals isPersonalDarwin (
      with pkgs;
      [
        qq
        wechat
      ]
    )
  );

  # ---- desktop applications ----
  custom.home.stacks.desktop.aerospace.enable = lib.mkForce false;
  custom.home.stacks.desktop.wezterm.enable = lib.mkForce false;
  custom.home.stacks.desktop.firefox.enable = lib.mkForce false;
  custom.home.stacks.desktop.thunderbird.enable = lib.mkForce false;
  custom.home.stacks.desktop.vscode.enable = lib.mkForce isPersonalDarwin;
  custom.home.stacks.desktop.zotero.enable = lib.mkForce isPersonalDarwin;

  # ---- commandline tools ----
  custom.home.stacks.commandline.editor.variant = lib.mkForce "none"; # 关闭nvim
  custom.home.stacks.commandline.editor.lsp.enable = lib.mkForce false;
  custom.home.stacks.commandline.git.ui = lib.mkForce "gitui";
  custom.home.stacks.commandline.shell.starship.enable = lib.mkForce true;
  custom.home.stacks.commandline.rclone.enable = lib.mkForce false;
  custom.home.stacks.commandline.claudecode.enable = lib.mkForce true;
  custom.home.stacks.commandline.codex.enable = lib.mkForce isPersonalDarwin;

  # Claude Code is installed declaratively, while each machine keeps its own
  # account state and settings instead of inheriting upstream's declared JSON.
  home.mutableFile = {
    ".claude.json".ownership.default = lib.mkForce "local";
    ".claude/settings.json".ownership.default = lib.mkForce "local";
  }
  // lib.optionalAttrs isPersonalDarwin {
    # Preserve Codex desktop/CLI-generated state locally. The shared module
    # still supplies stable defaults for keys not covered by these sections.
    ".codex/config.toml".ownership.rules = lib.mkAfter [
      {
        path = [ "marketplaces" ];
        mode = "local";
      }
      {
        path = [ "plugins" ];
        mode = "local";
      }
      {
        path = [ "features" ];
        mode = "local";
      }
      {
        path = [ "desktop" ];
        mode = "local";
      }
      {
        path = [ "shell_environment_policy" ];
        mode = "local";
      }
    ];
  };

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
      ''
      + builtins.readFile ./init.zsh
    );
  };

  home.file.zsh-plugins = {
    enable = true;
    source = ../../home/commandline/zsh/plugins;
    target = ".local/zsh_plugins/plugins";
    recursive = true;
  };

  home.file.".ssh/config.d/config" = lib.mkIf isPersonalDarwin {
    source = ./ssh-config;
  };

  home.file."Library/Application Support/iTerm2/DynamicProfiles/dream.json" =
    lib.mkIf isPersonalDarwin
      {
        source = ./iterm2-profile.json;
      };

  # ---- fish: shellInit ----
  programs.fish = {
    enable = lib.mkForce true;
    shellInit = builtins.readFile ./init.fish;
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

  # ---- VS Code: portable subset of the current local settings ----
  programs.vscode.profiles.default = lib.mkIf isPersonalDarwin {
    userSettings = lib.mapAttrs (_: lib.mkForce) {
      "update.mode" = "manual";
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;

      "workbench.iconTheme" = "material-icon-theme";
      "workbench.colorTheme" = "One Dark Pro Darker";
      "workbench.tree.enableStickyScroll" = true;
      "workbench.editor.empty.hint" = "hidden";
      "workbench.layoutControl.enabled" = false;

      "explorer.confirmDelete" = false;
      "explorer.compactFolders" = false;
      "explorer.confirmPasteNative" = false;

      "editor.accessibilitySupport" = "off";
      "editor.fontSize" = 13;
      "editor.fontFamily" =
        "FiraCode Nerd Font Mono, JetBrains Mono NL, Consolas, 'Courier New', monospace";
      "editor.formatOnType" = true;
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.unicodeHighlight.allowedLocales" = {
        "zh-hans" = true;
      };

      "window.openFoldersInNewWindow" = "on";
      "window.commandCenter" = false;

      "terminal.integrated.macOptionClickForcesSelection" = true;
      "terminal.integrated.cwd" = "\${workspaceFolder}";
      "terminal.integrated.fontFamily" =
        "FiraMono Nerd Font Mono, JetBrains Mono NL, Consolas, 'Courier New', monospace";
      "terminal.integrated.fontWeight" = "normal";
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.defaultProfile.osx" = "fish";
      "terminal.integrated.profiles.osx" = {
        fish.path = "/etc/profiles/per-user/${hostMeta.username}/bin/fish";
      };

      "files.restoreUndoStack" = false;
      "files.autoGuessEncoding" = true;
      "files.autoSave" = "onFocusChange";

      "remote.SSH.lockfilesInTmp" = true;
      "remote.downloadExtensionsLocally" = true;

      "python.terminal.activateEnvironment" = false;
      "python.analysis.autoFormatStrings" = true;
      "python.analysis.inlayHints.callArgumentNames" = "partial";
      "python.analysis.inlayHints.functionReturnTypes" = true;
      "python.analysis.typeCheckingMode" = "standard";

      "C_Cpp.formatting" = "vcFormat";
      "C_Cpp.default.cStandard" = "c17";
      "C_Cpp.default.cppStandard" = "c++20";

      "github.copilot.enable" = {
        "*" = false;
        plaintext = false;
        markdown = false;
        scminput = false;
      };
    };

    keybindings = lib.mkAfter [
      {
        key = "ctrl+cmd+n";
        command = "explorer.newFile";
      }
      {
        key = "shift+cmd+n";
        command = "explorer.newFolder";
      }
      {
        key = "ctrl+r";
        command = "code-runner.run";
      }
      {
        key = "alt+cmd+l";
        command = "editor.action.formatSelection";
        when = "editorHasDocumentSelectionFormattingProvider && editorTextFocus && !editorReadonly";
      }
      {
        key = "cmd+k cmd+n";
        command = "chatgpt.newCodexPanel";
      }
    ];
  };

  # ---- extra packages ----
  home.packages = with pkgs; [
    kubectl
  ];
}
