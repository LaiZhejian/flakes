{ config, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
      };
    };

    shellWrapperName = "y";
  };

  # Override the `builtin cd` to `cd` to record the directory history in fish
  # Source:
  #   https://github.com/nix-community/home-manager/blob/0d02ec1d0a05f88ef9e74b516842900c41f0f2fe/modules/programs/yazi.nix#L235
  # Related issues:
  #   https://github.com/sxyazi/yazi/discussions/1964
  #   https://github.com/sxyazi/yazi/issues/2859
  programs.fish.functions.${config.programs.yazi.shellWrapperName} = lib.mkForce ''
    set -l tmp (mktemp -t "yazi-cwd.XXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      cd -- "$cwd"
    end
    rm -f -- "$tmp"
  '';
}
