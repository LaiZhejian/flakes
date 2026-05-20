{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
    extraConfig = ''
      ClientAliveInterval 30
      ClientAliveCountMax 60
    '';
  };
  services.fail2ban.enable = true;
}
