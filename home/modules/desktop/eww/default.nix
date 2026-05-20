{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.eww = {
    enable = true;
    configDir = ./.;
  };

  systemd.user.services.eww =
    let
      dependencies = with pkgs; [
        config.wayland.windowManager.hyprland.package

        bash
        blueberry
        bluez
        brillo
        coreutils
        dbus
        findutils
        gawk
        gnome.gnome-control-center
        gnused
        imagemagick
        jaq
        jc
        libnotify
        networkmanager
        pavucontrol
        playerctl
        procps
        pulseaudio
        ripgrep
        socat
        udev
        upower
        util-linux
        wget
        wireplumber
        wlogout
      ];
    in
    {
      Unit = {
        Description = "Eww Daemon";
        # not yet implemented
        # PartOf = ["tray.target"];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
        ExecStart = "${config.programs.eww.package}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
}
