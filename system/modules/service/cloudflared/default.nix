{ ... }:

{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "29743e09-3d8d-418c-88c5-99a2e7489453" = {
        credentialsFile = "/etc/cloudflared/29743e09-3d8d-418c-88c5-99a2e7489453.json";
        warp-routing.enabled = true;
        ingress = {
          "www.lihan.fun/work/80" = "http://localhost:80";
          "www.lihan.fun/work/7777" = "http://localhost:7777";
          "www.lihan.fun/ssh/work" = "ssh://localhost:22";
        };
        default = "http_status:404";
      };
    };
  };
}
