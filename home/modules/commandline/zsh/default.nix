{ config, ... }:

{
  programs.zsh = {
    enable = true;

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

    autocd = true;
    history.size = 10000;
    history.save = 100000;
    history.share = false;
    history.ignoreDups = true;
    history.extended = true;
    initContent = builtins.readFile ./init.zsh;
  };

  home.file.zsh-plugins = {
    enable = true;
    source = ./plugins;
    target = "${config.home.homeDirectory}/.local/zsh_plugins/plugins";
    recursive = true;
  };
}
