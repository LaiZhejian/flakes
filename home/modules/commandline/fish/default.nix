{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./init.fish;
  };

  # A replacement for command-not-found in nix
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # [https://wiki.nixos.org/wiki/Fish](https://wiki.nixos.org/w/index.php?title=Fish&oldid=1222)
  # Using fish as login shell may cause issues because fish is not POSIX compliant.
  # So we keep bash as the system shell but have it exec fish when run interactively. 
  # To keep compatible with darwin, we use posix arguments for ps.
  programs.bash.initExtra = ''
    if [[ ! $(${pkgs.procps}/bin/ps -o comm= -p "$PPID") =~ (bash|zsh|fish)$ && -z "''${BASH_EXECUTION_STRING}" ]]
    then
      declare -a SHELL_OPTION
      case $- in
        *i*) SHELL_OPTION+=("-i")
      esac
      shopt -q login_shell && SHELL_OPTION+=("--login")
      exec ${pkgs.fish}/bin/fish "''${SHELL_OPTION[@]}"
    fi
  '';
  programs.zsh.initContent = ''
    if [[ ! $(${pkgs.procps}/bin/ps -o comm= -p "$PPID") =~ (bash|zsh|fish)$ && -z "''${ZSH_EXECUTION_STRING}" ]]
    then
      typeset -a SHELL_OPTION
      case $- in
        *i*) SHELL_OPTION+=("-i")
      esac
      case $- in
        *l*) SHELL_OPTION+=("--login")
      esac
      exec ${pkgs.fish}/bin/fish "''${SHELL_OPTION[@]}"
    fi
  '';
}
