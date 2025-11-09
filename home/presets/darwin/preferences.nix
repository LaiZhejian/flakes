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

      "Apple Global Domain" = {
        AppleMeasurementUnits = "Centimeters";
        AppleMenuBarVisibleInFullscreen = 0;
        AppleMetricUnits = 1;
        AppleMiniaturizeOnDoubleClick = 0;
        ApplePressAndHoldEnabled = 0;
        AppleShowAllExtensions = 1;
        AppleTemperatureUnit = "Celsius";
        InitialKeyRepeat = 25;
        "InitialKeyRepeat_Level_Saved" = 4;
        "KB_DoubleQuoteOption" = "\\U201cabc\\U201d";
        "KB_SingleQuoteOption" = "\\U2018abc\\U2019";
        "KB_SpellingLanguage" = {
          "KB_SpellingLanguageIsAutomatic" = 1;
        };
        KeyRepeat = 2;
        NSAllowContinuousSpellChecking = 0;
        NSAutomaticCapitalizationEnabled = 0;
        NSAutomaticDashSubstitutionEnabled = 0;
        NSAutomaticPeriodSubstitutionEnabled = 0;
        NSAutomaticQuoteSubstitutionEnabled = 0;
        NSAutomaticSpellingCorrectionEnabled = 1;
        NSAutomaticTextCompletionEnabled = 0;
        NSNavPanelFileLastListModeForOpenModeKey = 1;
        NSNavPanelFileListModeForOpenMode2 = 1;
        NSPreferredWebServices = {
          NSWebServicesProviderWebSearch = {
            NSDefaultDisplayName = "Baidu";
            NSProviderIdentifier = "com.baidu.www";
          };
        };
        NavPanelFileListModeForOpenMode = 1;
        TISRomanSwitchState = 1;
        WebAutomaticSpellingCorrectionEnabled = 1;
        "com.apple.finder.SyncExtensions" = {
          collaborationMap = { };
          dirMap = { };
        };
        "com.apple.keyboard.fnState" = 1;
        "com.apple.mouse.scaling" = "0.875";
        "com.apple.scrollwheel.scaling" = "0.3125";
        "com.apple.sound.beep.flash" = 0;
        "com.apple.sound.beep.sound" = "/System/Library/Sounds/Pop.aiff";
        "com.apple.sound.beep.volume" = "0.6187834";
        "com.apple.springing.delay" = "0.5";
        "com.apple.springing.enabled" = 1;
        "com.apple.swipescrolldirection" = 0;
        "com.apple.trackpad.forceClick" = 1;
        "com.apple.trackpad.scaling" = 1;
        "com.apple.trackpad.scrolling" = "0.3125";
      };

      "com.apple.AppleMultitouchTrackpad" = {
        ActuateDetents = 1;
        Clicking = 1;
        DragLock = 0;
        Dragging = 0;
        FirstClickThreshold = 0;
        ForceSuppressed = 0;
        SecondClickThreshold = 0;
        TrackpadCornerSecondaryClick = 0;
        TrackpadFiveFingerPinchGesture = 2;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadHandResting = 1;
        TrackpadHorizScroll = 1;
        TrackpadMomentumScroll = 1;
        TrackpadPinch = 1;
        TrackpadRightClick = 1;
        TrackpadRotate = 1;
        TrackpadScroll = 1;
        TrackpadThreeFingerDrag = 1;
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 0;
        TrackpadTwoFingerDoubleTapGesture = 1;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        USBMouseStopsTrackpad = 0;
        UserPreferences = 1;
        version = 12;
      };

      "com.apple.Siri" = {
        HotkeyTag = 0;
        SiriPrefStashedStatusMenuVisible = 0;
        StatusMenuVisible = 0;
        VoiceTriggerUserEnabled = 0;
      };

      "com.apple.WindowManager" = {
        AppWindowGroupingBehavior = 1;
        AutoHide = 0;
        EnableTiledWindowMargins = 0;
        EnableTilingByEdgeDrag = 0;
        EnableTopTilingByEdgeDrag = 0;
        GloballyEnabled = 1;
        GloballyEnabledEver = 1;
        HideDesktop = 1;
        StageManagerHideWidgets = 1;
        StandardHideDesktopIcons = 0;
        StandardHideWidgets = 0;
      };

      "com.apple.menuextra.clock" = {
        FlashDateSeparators = false;
        IsAnalog = false;
        ShowAMPM = false;
        ShowDate = 0;
        ShowDayOfWeek = true;
        ShowSeconds = false;
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
