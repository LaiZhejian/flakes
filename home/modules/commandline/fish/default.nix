{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./init.fish;
  };

  # [https://wiki.nixos.org/wiki/Fish](https://wiki.nixos.org/w/index.php?title=Fish&oldid=1222)
  # Using fish as login shell may cause issues because fish is not POSIX compliant.
  # So we keep bash as the system shell but have it exec fish when run interactively.
  # To keep compatible with darwin, we use posix arguments for ps.
  programs.bash.initExtra = ''
    if [[ "''${AUTO_ENTER_FISH:-}" != "0" && ! $(${pkgs.procps}/bin/ps -o comm= -p "$PPID") =~ (bash|zsh|fish)$ && -z "''${BASH_EXECUTION_STRING}" ]]
    then
      declare -a SHELL_OPTION
      if [[ $- == *i* ]]; then
        SHELL_OPTION+=("--interactive")
      fi
      if shopt -q login_shell; then
        SHELL_OPTION+=("--login")
      fi
      exec ${pkgs.fish}/bin/fish "''${SHELL_OPTION[@]}"
    fi
  '';
  programs.zsh.initContent = ''
    if [[ "''${AUTO_ENTER_FISH:-}" != "0" && ! $(${pkgs.procps}/bin/ps -o comm= -p "$PPID") =~ (bash|zsh|fish)$ && -z "''${ZSH_EXECUTION_STRING}" ]]
    then
      typeset -a SHELL_OPTION
      if [[ $- == *i* ]]; then
        SHELL_OPTION+=("--interactive")
      fi
      if [[ -o login ]]; then
        SHELL_OPTION+=("--login")
      fi
      exec ${pkgs.fish}/bin/fish "''${SHELL_OPTION[@]}"
    fi
  '';
}
