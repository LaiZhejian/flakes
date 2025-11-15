{ config, pkgs, lib, ... }:

{
  targets.darwin = {
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
      
    };
  };

  # Set Home and End keys to move to the beginning and end of lines like Windows
  # https://discussions.apple.com/thread/251108215?sortBy=rank
  home.file."Library/KeyBindings/DefaultKeyBinding.dict" = {
    enable = true;
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
