{ ... }:

{
  # Start with Dream's Darwin system defaults. Because that module derives the
  # account from hostMeta, this creates the `bytedance` user and attaches this
  # host's Home Manager configuration without duplicating the shared settings.
  imports = [
    ../dream/system.nix
  ];

  custom.system.users.bytedance.homeConfiguration = ./home.nix;
}
