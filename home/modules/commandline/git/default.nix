{ config, lib, ... }:

let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkOption;
  cfg = config.customize.git;
in
{
  options.customize.git = {
    signing = {
      enable = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Whether to enable commit signing.";
      };
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = "Jackie_Lai";
      userEmail = "742949301@qq.com";

      aliases = {
        graph = "log --all --decorate --oneline --graph";
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
        lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
        root = "rev-parse --show-toplevel";
      };

      difftastic = {
        enable = true;
      };

      ignores = [ ".cache" "compile_commands.json" ];

      extraConfig = {
        init.defaultBranch = "main";
        core.autocrlf = "input";
        pull.rebase = false;
        push.autoSetupRemote = true;
        merge.conflictStyle = "zdiff3";
        rebase.autostash = true;
        log.date = "iso";
        column.ui = "auto";
        branch.sort = "committerdate";
      };
    };

    programs.gpg.enable = true;
  };
}
