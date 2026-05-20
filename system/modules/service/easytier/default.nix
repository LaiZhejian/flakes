{ pkgs, ... }:

{
  systemd.services.easytier = {
    enable = true;
    description = "EasyTier - A simple, safe, decentralized intranet penetration tool";
    after = [
      "network.target"
      "syslog.target"
    ];
    wants = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${pkgs.easytier}/bin/easytier-core --config-file /etc/easytier/config.toml";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
