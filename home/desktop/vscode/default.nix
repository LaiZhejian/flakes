{
  pkgs,
  lib,
  config,
  ...
}@args:

let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  cfg = config.customize.vscode;

  configDir = "Code";
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/${configDir}/User"
    else
      "${config.xdg.configHome}/${configDir}/User";
  configFilePath =
    name: "${userDir}/${lib.optionalString (name != "default") "profiles/${name}/"}settings.json";

  marketplace = (import ./extensions.nix) args;
  # Only extensions whose name is not in cfg.extensions.exclude are added
  filterExtensions =
    extList:
    builtins.filter (
      ext:
      lib.lists.all (excludedName: !(lib.strings.hasInfix excludedName ext.name)) cfg.extensions.exclude
    ) extList;
in
{
  imports = [
    ./lang-cpp.nix
    ./lang-java.nix
    ./lang-javascript.nix
    ./lang-kotlin.nix
    ./lang-python.nix
    ./lang-rust.nix
    ./env-nix.nix
  ];

  options.custom = {
    home.stacks.desktop.vscode = {
      enable = lib.mkEnableOption "Enable VS Code configuration.";
    };
  };

  options.customize.vscode = {
    extensions = {
      presets = {
        all = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = "Whether to enable all the extension presets except specially specified.";
        };
      };
      include = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = ''
          Add some extensions
        '';
        example = lib.literalExpression ''
          [ wakatime.vscode-wakatime github.copilot github.copilot-chat ]
        '';
      };
      exclude = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Exclude some extensions
        '';
        example = lib.literalExpression ''
          [ "wakatime.vscode-wakatime" "github.copilot" "github.copilot-chat" ]
        '';
      };
    };
  };

  config = lib.mkIf config.custom.home.stacks.desktop.vscode.enable {
    customize.vscode.extensions.include = with marketplace; [
      smcpeak.default-keys-windows
      ms-vscode.hexeditor
      usernamehw.errorlens
      mhutchie.git-graph
      formulahendry.code-runner
      openai.chatgpt
      pkief.material-icon-theme
      zhuangtongfa.material-theme
      wakatime.vscode-wakatime
      tamasfe.even-better-toml

      ms-vscode-remote.remote-ssh
    ];

    # Replace the immutable settings.json to mutable one.
    home.file."${configFilePath "default"}".enable = false;
    home.mutableFile."${configFilePath "default"}" = {
      format = "json";
      source = config.home.file."${configFilePath "default"}".source;
    };

    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = filterExtensions cfg.extensions.include;

        userSettings =
          let
            addPrefix =
              prefix: attr:
              lib.attrsets.mapAttrs' (name: value: {
                name = "${prefix}.${name}";
                value = value;
              }) attr;
          in
          (addPrefix "editor" {
            fontFamily = "'Cascadia Code NF', 'Cascadia Code', 'CaskaydiaCove Nerd Font', 'HarmonyOS Sans', 'Noto Sans CJK SC', 'Source Han Sans SC', Consolas, 'Courier New', monospace";
            # customized for Cascadia Code NF, see https://github.com/microsoft/cascadia-code?tab=readme-ov-file#font-features
            fontLigatures = true;
            # customized for Monaspace Neon, see http://monaspace.githubnext.com/#code-ligatures
            # fontLigatures = "'calt', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'ss09', 'liga'";

            formatOnPaste = false;
            formatOnSave = false;
            formatOnType = false;

            mouseWheelZoom = true;
          })
          // {
            "remote.SSH.configFile" = "${config.home.homeDirectory}/.vscode/remote-ssh-config";
            "settingsSync.ignoredSettings" = [
              "remote.SSH.configFile"
              "remote.SSH.remotePlatform"
            ];

            "update.mode" = "none";
            "extensions.autoUpdate" = false;

            "git.confirmSync" = false;
            "explorer.confirmDragAndDrop" = true;
            "explorer.confirmDelete" = false;
            "terminal.integrated.enableMultiLinePasteWarning" = "never";
            "diffEditor.ignoreTrimWhitespace" = false;

            "[json]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
            "[jsonl]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
            "[jsonc]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
          }
          // (addPrefix "terminal.integrated" {
            accessibleViewPreserveCursorPosition = true;
            "defaultProfile.linux" = "fish";
            "defaultProfile.osx" = "fish";
            # 100,000 is too large for VS Code. It gets stuck frequently.
            # "scrollback" = 100000;
          });

        keybindings = [
          {
            key = "ctrl+q";
            command = "-workbench.action.quickOpenNavigateNextInViewPicker";
            when = "inQuickOpen && inViewsPicker";
          }
          {
            key = "ctrl+q";
            command = "-workbench.action.quickOpenView";
          }
          {
            key = "ctrl+j";
            command = "-workbench.action.togglePanel";
          }
          {
            key = "shift+enter";
            command = "workbench.action.terminal.sendSequence";
            args = {
              text = builtins.fromJSON ''"\u001b\r"''; # Nix does not support \u escape, use fromJSON to workaround
            };
            when = "terminalFocus";
          }
          {
            key = "ctrl+shift+`";
            command = "workbench.action.toggleMaximizedPanel";
          }
          {
            key = "ctrl+shift+`";
            command = "-workbench.action.terminal.new";
            when = "terminalProcessSupported || terminalWebExtensionContributedProfile";
          }
        ];
      };
    };
  };
}
