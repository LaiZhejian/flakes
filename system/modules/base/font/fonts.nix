{ pkgs, lib, ... }:

{
  fonts = {
    packages = with pkgs; [
      # noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.fira-mono
      # source-han-sans
      # source-han-serif
      # cascadia-code
      # jetbrains-mono
      # monaspace
      # nerd-fonts.symbols-only
      # nerd-fonts.caskaydia-cove
      # nerd-fonts.jetbrains-mono
    ];
  };
}
