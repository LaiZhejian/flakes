{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  homebrew = {
    # TODO: this is a workaround for https://github.com/nix-darwin/nix-darwin/pull/1341
    # In the long run, this setting will be deprecated and removed after all the
    # functionality it is relevant for has been adjusted to allow
    # specifying the relevant user separately, moved under the
    # `users.users.*` namespace, or migrated to Home Manager.
    user = config.hostSpec.primaryUser;
    enable = true;
    casks = [
      # "mos"
      # "rwts-pdfwriter"
      # "clash-verge-rev"
      # "wezterm"   # installed by nix
      # "visual-studio-code"  # installed by nix
      # "sogou-input" # no longer available in homebrew
      # "qq" # installed by nix
      # "wechat" #installed by nix
      # "thunderbird" # installed by nix
      # "zotero" # installed by nix
      # "zerotier-one"
      "1password-cli"
      "keyboardcleantool"
      "surge"
    ];
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  nix-homebrew = {
    user = config.hostSpec.primaryUser;
    enable = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      # "nikitabobko/homebrew-aerospace" = inputs.homebrew-aerospace;   # Aerospace is installed by nix
      # "recronin/homebrew-sogou-input" = inputs.homebrew-sogou-input;  # no longer available in homebrew
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}
