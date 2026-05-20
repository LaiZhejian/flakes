{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        "invalid users" = [ "root" ];
        "passwd program" = "/run/wrappers/bin/passwd %u";
        "guest account" = "nobody";
        "hosts allow" = "0.0.0.0/0";
      };
      home = {
        browseable = "yes";
        comment = "Home directory for %u";
        path = "/home/%u";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      public = {
        browseable = "yes";
        comment = "Public samba share.";
        path = "/srv/public";
        "guest ok" = "yes";
        "force user" = "nobody";
        "read only" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
