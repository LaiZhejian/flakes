{
  hostMeta,
  lib,
  pkgs,
  ...
}:

let
  isPersonalDarwin = hostMeta.username == "dream";
in
{
  targets.darwin = lib.mkIf pkgs.stdenv.isDarwin {
    defaults = {
      ".GlobalPreferences_m" = {
        AppleLanguages = [
          "en-CN"
          "zh-Hans-CN"
        ];
        AppleLocale = "en_CN";
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
      };

      "com.apple.dock" = {
        autohide = true;
      };
    }
    // lib.optionalAttrs isPersonalDarwin {
      # Alfred reads a host-managed preference set instead of using iCloud.
      "com.runningwithcrayons.Alfred-Preferences" = {
        syncfolder = "~/.config/alfred";
      };
      "com.runningwithcrayons.Alfred" = {
        "appearance.screen" = 0;
      };

      # Stable iTerm2 application preferences. Profiles are managed separately
      # through a Dynamic Profile in hosts/dream/iterm2-profile.json.
      "com.googlecode.iterm2" = {
        PromptOnQuit = true;
        CopySelection = true;
        OpenArrangementAtStartup = false;
        SUEnableAutomaticChecks = true;
        "Default Bookmark Guid" = "8A0239C2-BBD9-4999-A844-DAA9F9E6D805";
      };

      "com.hegenberg.KeyboardCleanTool" = {
        startAfterStart = true;
      };
    };
  };

  home.file."Library/KeyBindings/DefaultKeyBinding.dict" = {
    enable = false;
    text = ''
      {
        "\UF729" = "moveToBeginningOfLine:"; /* Home */
        "\UF72B" = "moveToEndOfLine:"; /* End */
        "$\UF729" = "moveToBeginningOfLineAndModifySelection:"; /* Shift + Home */
        "$\UF72B" = "moveToEndOfLineAndModifySelection:"; /* Shift + End */
        "^\UF729" = "moveToBeginningOfDocument:"; /* Ctrl + Home */
        "^\UF72B" = "moveToEndOfDocument:"; /* Ctrl + End */
        "$^\UF729" = "moveToBeginningOfDocumentAndModifySelection:"; /* Shift + Ctrl + Home */
        "$^\UF72B" = "moveToEndOfDocumentAndModifySelection:"; /* Shift + Ctrl + End */
      }
    '';
  };
}
