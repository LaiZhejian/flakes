{ config, lib, ... }:

let
  inherit (lib) types mkDefault;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkOption;
  cfg = config.customize.git;
in
{
  config = {
    programs.git = {
      enable = true;
      ignores = [
        ".cache"
        "compile_commands.json"
      ];

      signing = {
        signByDefault = mkDefault true;
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };

      settings = lib.mkMerge [
        {
          user.name = "Jackie_Lai";
          user.email = "742949301@qq.com";

          alias = {
            graph = "log --all --decorate --oneline --graph";
            lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
            lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
            root = "rev-parse --show-toplevel";
            difft = "-c diff.external=difft diff";
          };

          init.defaultBranch = "main";
          core.autocrlf = "input";
          pull.rebase = false;
          push.autoSetupRemote = true;
          merge.conflictStyle = "zdiff3";
          rebase.autostash = true;
          log.date = "iso";
          column.ui = "auto";
          branch.sort = "committerdate";
          safe.directory = "*";
        }
      ];

    };
    programs.difftastic = {
      enable = true;
      git.enable = false;
    };
    programs.gpg.enable = true;
  };
}
