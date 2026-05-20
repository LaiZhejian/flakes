{
  config,
  pkgs,
  lib,
  isDarwin,
  ...
}:

lib.optionalAttrs isDarwin {
  # Allow sudo authentication with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;
}
