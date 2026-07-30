{
  config,
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

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        "com.apple.keyboard.fnState" = 1;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.forceClick" = true;
        "com.apple.trackpad.scaling" = 1.0;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = true;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.finder" = {
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "PfLo";
        NewWindowTargetPath = "file://${config.home.homeDirectory}/Downloads/";
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowPathbar = false;
        ShowRemovableMediaOnDesktop = false;
        ShowStatusBar = false;
      };

      "com.apple.dock" = {
        autohide = true;
        launchanim = false;
        magnification = false;
        mineffect = "scale";
        show-recents = false;
        tilesize = 60;
        wvous-tl-corner = 10;
        wvous-tr-corner = 1;
        wvous-bl-corner = 4;
        wvous-br-corner = 13;
      };

      "com.apple.AppleMultitouchTrackpad" = {
        Clicking = true;
        Dragging = false;
        FirstClickThreshold = 0;
        SecondClickThreshold = 0;
        TrackpadCornerSecondaryClick = 0;
        TrackpadFiveFingerPinchGesture = 2;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadHorizScroll = true;
        TrackpadMomentumScroll = true;
        TrackpadPinch = true;
        TrackpadRightClick = true;
        TrackpadRotate = true;
        TrackpadScroll = true;
        TrackpadThreeFingerDrag = true;
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 0;
        TrackpadTwoFingerDoubleTapGesture = 1;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };

      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        Clicking = true;
        Dragging = false;
        TrackpadRightClick = true;
      };

      "com.apple.WindowManager" = {
        AppWindowGroupingBehavior = 1;
        AutoHide = 0;
        EnableStandardClickToShowDesktop = 1;
        EnableTiledWindowMargins = 0;
        EnableTilingByEdgeDrag = 0;
        EnableTopTilingByEdgeDrag = 0;
        GloballyEnabled = 1;
      };

      "com.apple.menuextra.clock" = {
        FlashDateSeparators = false;
        IsAnalog = false;
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 0;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };

      # Explicit security policy: require authentication immediately.
      "com.apple.screensaver" = {
        askForPassword = 1;
        askForPasswordDelay = 0;
      };

      "com.apple.Siri" = {
        StatusMenuVisible = 0;
        VoiceTriggerUserEnabled = 0;
      };

      # Preserve both enabled and disabled entries from Keyboard Shortcuts.
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = builtins.fromJSON (builtins.readFile ./symbolic-hotkeys.json);
      };
    }
    // lib.optionalAttrs isPersonalDarwin {
      "com.googlecode.iterm2" = {
        PromptOnQuit = true;
        CopySelection = true;
        OpenArrangementAtStartup = false;
        SUEnableAutomaticChecks = true;
        "Default Bookmark Guid" = "ED2D5D5A-4C80-456B-8329-23C9FA09374C";
      };

      "com.hegenberg.KeyboardCleanTool" = {
        startAfterStart = true;
      };
    };
  };
}
