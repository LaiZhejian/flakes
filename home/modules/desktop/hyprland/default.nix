{
  pkgs,
  lib,
  config,
  ...
}:

let
  mathmod = x: m: x - (x / m) * m;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";

      "exec-once" = "fcitx5 -d --replace";

      general = {
        border_size = 0;
        gaps_in = 1;
        gaps_out = 0;
        resize_on_border = true;
      };

      monitor = [
        "DP-1, 3840x2160@60, 0x0, 1.5"
      ];

      bindm = [
        # Mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      bind = [
        "$mod, F11, fullscreen,"
        "$mod, s, togglesplit,"
        "$mod, t, togglefloating,"
        "$mod, q, killactive,"
        "$mod SHIFT, Q, exec, hyprctl dispatch exit 1"

        "$mod, Left, movefocus, l"
        "$mod, Right, movefocus, r"
        "$mod, Up, movefocus, u"
        "$mod, Down, movefocus, d"

        "$mod CTRL, Left, workspace, m-1"
        "$mod CTRL, Right, workspace, m+1"

      ]
      ++ (
        # $mod + {1..0} to switch workspace {1..10}
        builtins.genList (x: "$mod, ${toString (mathmod (x + 1) 10)}, workspace, ${toString (x + 1)}") 10
      )
      ++ (
        # $mod SHIFT + {1..0} to move window to workspace {1..10}
        builtins.genList (
          x: "$mod SHIFT, ${toString (mathmod (x + 1) 10)}, movetoworkspace, ${toString (x + 1)}"
        ) 10
      )
      ++ (lib.optionals config.programs.wezterm.enable [
        "$mod, Return, exec, ${lib.getExe config.programs.wezterm.package}"
      ])
      ++ (
        # Notification manager
        let
          makoctl = lib.getExe' config.services.mako.package "makoctl";
        in
        [
          "$mod, w, exec, ${makoctl} dismiss"
        ]
      )
      ++ (
        # Launcher
        let
          wofi = lib.getExe config.programs.wofi.package;
        in
        [
          "$mod, x, exec, ${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
          # "$mod, s, exec, specialisation $(specialisation | ${wofi} -S dmenu)"
          "$mod, r, exec, ${wofi} -S run"
        ]
      );

    };
  };
}
