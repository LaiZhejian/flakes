{ pkgs, lib, ... }:

let
  keys = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "0"
    "q"
    "w"
    "e"
    "r"
    "t"
    "y"
    "u"
    "i"
    "o"
    "p"
  ];
in
{
  imports = [
    ./preferences-fix.nix
  ];

  programs.aerospace = {
    enable = true;
    launchd.enable = false;
    settings = {
      default-root-container-layout = "accordion";
      default-root-container-orientation = "auto";
      automatically-unhide-macos-hidden-apps = true;
      accordion-padding = 30;

      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
        alt-tab = "workspace-back-and-forth";
        # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        # See: https://nikitabobko.github.io/AeroSpace/commands#mode
        alt-shift-semicolon = "mode service";
      }
      // (lib.listToAttrs (
        lib.imap0 (i: key: {
          name = "alt-${key}";
          value = "workspace ${key}";
        }) keys
      ))
      // (lib.listToAttrs (
        lib.imap0 (i: key: {
          name = "alt-shift-${key}";
          value = "move-node-to-workspace ${key}";
        }) keys
      ));

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ]; # reset layout
        f = [
          "layout floating tiling"
          "mode main"
        ]; # Toggle between floating and tiling layout
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
        #s = ["layout sticky tiling" "mode main"]

        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];

        down = "volume down";
        up = "volume up";
        shift-down = [
          "volume set 0"
          "mode main"
        ];
      };

      # All possible keys:
      # - Letters.        a, b, c, ..., z
      # - Numbers.        0, 1, 2, ..., 9
      # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
      # - F-keys.         f1, f2, ..., f20
      # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon,
      #                   backtick, leftSquareBracket, rightSquareBracket, space, enter, esc,
      #                   backspace, tab
      # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
      #                   keypadMinus, keypadMultiply, keypadPlus
      # - Arrows.         left, down, up, right

      # All possible modifiers: cmd, alt, ctrl, shift

      # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

      # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
      # You can uncomment the following lines to open up terminal with alt + enter shortcut
      # (like in i3)
      # alt-enter = '''exec-and-forget osascript -e '
      # tell application "Terminal"
      #     do script
      #     activate
      # end tell'
      # '''

      # See: https://nikitabobko.github.io/AeroSpace/commands#layout

      # See: https://nikitabobko.github.io/AeroSpace/commands#focus
      # alt-h = 'focus left'
      # alt-j = 'focus down'
      # alt-k = 'focus up'
      # alt-l = 'focus right'

      # # See: https://nikitabobko.github.io/AeroSpace/commands#move
      # alt-shift-h = 'move left'
      # alt-shift-j = 'move down'
      # alt-shift-k = 'move up'
      # alt-shift-l = 'move right'
    };
  };
}
