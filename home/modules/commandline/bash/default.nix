{ ... }:

{
  programs.bash = {
    enable = true;
    historySize = 10000;
    historyFileSize = 100000;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
  };
}
