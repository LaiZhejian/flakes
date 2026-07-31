{
  lib,
  hostMeta,
  ...
}:

{
  # Dream's personal Darwin system defaults, shared with dream-bytedance.
  imports = [
    ./base/system
  ];

  # The base derives the account from hostMeta; this host attaches its own
  # Home Manager configuration. dream-bytedance overrides this with its own.
  custom.system.users.${hostMeta.username}.homeConfiguration = lib.mkDefault ./home.nix;
}
