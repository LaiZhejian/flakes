{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        default_prog = { "${pkgs.fish}/bin/fish" },
        font = wezterm.font_with_fallback({
          "Cascadia Code NF",
          "CaskaydiaCove Nerd Font",

          "Noto Sans CJK SC",
          "Source Han Sans CN",

          -- Fallback to Wezterm's built-in font if the above fonts are not available
          "JetBrains",
          "Noto Color Emoji",
          "Symbols Nerd Font",
        }),
        font_dirs = { "/Library/Fonts/Nix Fonts" },
        front_end = "WebGpu",
      }
    '';
  };
}
