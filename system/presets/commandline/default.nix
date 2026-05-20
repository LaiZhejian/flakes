{ pkgs, ... }:

{
  imports = [
    ../minimal

    ../../modules/service/ssh
    ../../modules/service/podman
    ../../modules/service/zerotierone
    ../../modules/service/easytier
    ../../modules/service/cloudflared
    ../../modules/service/samba
  ];
}
