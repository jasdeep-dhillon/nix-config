{ inputs, self, ... }:
{
  flake.nixosModules.niri = {
    imports = [
      inputs.home-manager.nixosModules.default
    ];
    home-manager.users.arc = {
      imports = [ self.homeModules.dms ];
    };
  };
  flake.nixosModules.niriShell =
    { pkgs, lib, ... }:
    let
      dms-exe = lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      runtimePkgs = [ inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      settings.environment = {
        DMS_DISABLE_MATUGEN = "1";
        DMS_DISABLE_CAVA = "1";
      };
      settings.spawn-at-startup = [
        [
          dms-exe
          "run"
        ]
      ];

      settings.switch-events = {
        lid-close = {
          spawn = [
            dms-exe
            "ipc"
            "call"
            "toast"
            "info"
            "Laptop Closed"
          ];
        };
        lid-open = {
          spawn = [
            dms-exe
            "ipc"
            "call"
            "toast"
            "info"
            "Laptop Opened"
          ];
        };
      };
      settings.binds = {
        "Mod+F5" = {
          spawn = [
            dms-exe
            "run"
          ];
        };
        "Mod+Space" = _: {
          props.cooldown-ms = 200;
          props.hotkey-overlay-title = "Launcher";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "spotlight"
            "toggle"
          ];
        };
        "Mod+V" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "clipboard"
            "toggle"
          ];
        };
        "Mod+Ctrl+Space" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "spotlight"
            "openQuery"
            "> "
          ];
        };
        "Mod+Period" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Emoji Picker";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "spotlight"
            "openQuery"
            ":e "
          ];
        };
        "Mod+F3" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Output Switch";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "audio"
            "cycleoutput"
          ];
        };
        "Mod+I" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Settings";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "settings"
            "toggle"
          ];
        };
        "Mod+F1" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Lock Screen";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "lock"
            "lock"
          ];
        };
        "Mod+Escape" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Power Menu";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "powermenu"
            "toggle"
          ];
        };
        "Mod+A" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Control Center";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "control-center"
            "toggle"
          ];
        };
        "Mod+N" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Notifications";
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "notifications"
            "toggle"
          ];
        };

        XF86MonBrightnessUp = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "brightness"
            "increment"
            "2"
            ''""''
          ];
        };
        "Mod+XF86AudioRaiseVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "brightness"
            "increment"
            "2"
            ''""''
          ];
        };
        "Mod+XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "brightness"
            "decrement"
            "2"
            ''""''
          ];
        };
        XF86MonBrightnessDown = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "brightness"
            "decrement"
            "2"
            ''""''
          ];
        };
        XF86AudioPlay = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "mpris"
            "playPause"
          ];
        };
        XF86AudioStop = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "mpris"
            "stop"
          ];
        };
        XF86AudioPrev = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "mpris"
            "previous"
          ];
        };
        XF86AudioNext = _: {
          props.allow-when-locked = true;
          content.spawn = [
            dms-exe
            "ipc"
            "call"
            "mpris"
            "next"
          ];
        };
      };
      settings.layer-rules = [
        {
          # matches = [
          #   {
          #     layer = "overlay";
          #   }
          # ];
          # background-effect = {
          #   blur = true;
          #   xray = true;
          # };
        }
      ];
    };

  flake.homeModules.dms =
    { config, pkgs, ... }:
    let
      theme = (pkgs.formats.json { }).generate "theme.json" {
        "dark" = {
          "primary" = "#b4befe";
          "primaryText" = "#1e1e2e";
          "primaryContainer" = "#3f4481";
          "secondary" = "#cba6f7";
          "surfaceTint" = "#2f3140";
          "surface" = "#181825";
          "surfaceText" = "#cdd6f4";
          "surfaceVariant" = "#1e1e2e";
          "surfaceVariantText" = "#a6adc8";
          "background" = "#1e1e2e";
          "backgroundText" = "#cdd6f4";
          "outline" = "#6c7086";
          "surfaceContainer" = "#1e1e2e";
          "surfaceContainerHigh" = "#313244";
          "surfaceContainerHighest" = "#45475a";
          "error" = "#f38ba8";
          "warning" = "#fab387";
          "info" = "#89b4fa";
        };
        "light" = {
          "primary" = "#7287fd";
          "primaryText" = "#eff1f5";
          "primaryContainer" = "#e5e8ff";
          "secondary" = "#8839ef";
          "surfaceTint" = "#e5e8ff";
          "surface" = "#e6e9ef";
          "surfaceText" = "#4c4f69";
          "surfaceVariant" = "#eff1f5";
          "surfaceVariantText" = "#6c6f85";
          "background" = "#eff1f5";
          "backgroundText" = "#4c4f69";
          "outline" = "#9ca0b0";
          "surfaceContainer" = "#e6e9ef";
          "surfaceContainerHigh" = "#ccd0da";
          "surfaceContainerHighest" = "#bcc0cc";
          "error" = "#d20f39";
          "warning" = "#fe640b";
          "info" = "#1e66f5";
        };
      };
    in
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.dms-plugin-registry.modules.default
      ];
      home.file.".face".source = self.avatar;
      programs.dank-material-shell = {
        enable = true;
        package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
        enableSystemMonitoring = true;
        enableVPN = true;
        enableClipboardPaste = true;
        enableDynamicTheming = false;
        plugins = {
          commandRunner.enable = true;
          emojiLauncher.enable = true;
          dankActions.enable = true;
          usbManager.enable = true;
        };
        settings = {
          currentThemeName = "custom";
          currentThemeCategory = "custom";
          customThemeFile = "${theme}";
          registryThemeVariants = { };
          matugenScheme = "scheme-tonal-spot";
          runUserMatugenTemplates = true;
          matugenTargetMonitor = "";
          popupTransparency = 0.75;
          dockTransparency = 0.75;
          widgetBackgroundColor = "sch";
          widgetColorMode = "default";
          controlCenterTileColorMode = "primary";
          buttonColorMode = "primary";
          cornerRadius = 12;
          niriLayoutGapsOverride = -1;
          niriLayoutRadiusOverride = -1;
          niriLayoutBorderSize = -1;
          hyprlandLayoutGapsOverride = -1;
          hyprlandLayoutRadiusOverride = -1;
          hyprlandLayoutBorderSize = -1;
          mangoLayoutGapsOverride = -1;
          mangoLayoutRadiusOverride = -1;
          mangoLayoutBorderSize = -1;
          use24HourClock = false;
          showSeconds = false;
          padHours12Hour = true;
          useFahrenheit = false;
          windSpeedUnit = "kmh";
          nightModeEnabled = false;
          animationSpeed = 1;
          customAnimationDuration = 500;
          syncComponentAnimationSpeeds = true;
          popoutAnimationSpeed = 1;
          popoutCustomAnimationDuration = 150;
          modalAnimationSpeed = 1;
          modalCustomAnimationDuration = 150;
          enableRippleEffects = true;
          blurEnabled = true;
          blurForegroundLayers = true;
          blurLayerOutlineOpacity = 0;
          blurBorderColor = "outline";
          blurBorderCustomColor = "#ffffff";
          blurBorderOpacity = 0.35;
          wallpaperFillMode = "Fill";
          blurredWallpaperLayer = false;
          blurWallpaperOnOverview = true;
          showLauncherButton = true;
          showWorkspaceSwitcher = true;
          showFocusedWindow = true;
          showWeather = true;
          showMusic = true;
          showClipboard = true;
          showCpuUsage = true;
          showMemUsage = true;
          showCpuTemp = true;
          showGpuTemp = true;
          selectedGpuIndex = 0;
          enabledGpuPciIds = [ ];
          showSystemTray = true;
          systemTrayIconTintMode = "none";
          systemTrayIconTintSaturation = 50;
          systemTrayIconTintStrength = 135;
          showClock = true;
          showNotificationButton = true;
          showBattery = true;
          showControlCenterButton = true;
          showCapsLockIndicator = true;
          controlCenterShowNetworkIcon = true;
          controlCenterShowBluetoothIcon = true;
          controlCenterShowAudioIcon = true;
          controlCenterShowAudioPercent = false;
          controlCenterShowVpnIcon = true;
          controlCenterShowBrightnessIcon = false;
          controlCenterShowBrightnessPercent = false;
          controlCenterShowMicIcon = false;
          controlCenterShowMicPercent = true;
          controlCenterShowBatteryIcon = false;
          controlCenterShowPrinterIcon = false;
          controlCenterShowScreenSharingIcon = true;
          showPrivacyButton = true;
          privacyShowMicIcon = false;
          privacyShowCameraIcon = false;
          privacyShowScreenShareIcon = false;
          controlCenterWidgets = [
            {
              enabled = true;
              id = "volumeSlider";
              width = 50;
            }
            {
              enabled = true;
              id = "brightnessSlider";
              width = 50;
            }
            {
              enabled = true;
              id = "wifi";
              width = 50;
            }
            {
              enabled = true;
              id = "bluetooth";
              width = 50;
            }
            {
              enabled = true;
              id = "audioOutput";
              width = 50;
            }
            {
              enabled = true;
              id = "audioInput";
              width = 50;
            }
            {
              enabled = true;
              id = "darkMode";
              width = 50;
            }
            {
              enabled = true;
              id = "idleInhibitor";
              width = 50;
            }
            {
              enabled = true;
              id = "battery";
              width = 50;
            }
            {
              enabled = true;
              id = "doNotDisturb";
              width = 50;
            }
            {
              enabled = true;
              id = "builtin_vpn";
              width = 50;
            }
            {
              enabled = true;
              id = "colorPicker";
              width = 50;
            }
          ];
          showWorkspaceIndex = true;
          showWorkspaceName = false;
          showWorkspacePadding = false;
          workspaceScrolling = true;
          showWorkspaceApps = true;
          workspaceDragReorder = true;
          maxWorkspaceIcons = 20;
          workspaceAppIconSizeOffset = 0;
          groupWorkspaceApps = false;
          workspaceFollowFocus = false;
          showOccupiedWorkspacesOnly = false;
          reverseScrolling = false;
          dwlShowAllTags = false;
          workspaceColorMode = "default";
          workspaceOccupiedColorMode = "none";
          workspaceUnfocusedColorMode = "s";
          workspaceUrgentColorMode = "default";
          workspaceFocusedBorderEnabled = false;
          workspaceFocusedBorderColor = "primary";
          workspaceFocusedBorderThickness = 2;
          workspaceNameIcons = {
            chat = {
              type = "icon";
              value = "headphones";
            };
            game = {
              type = "icon";
              value = "sports_esports";
            };
          };
          waveProgressEnabled = true;
          scrollTitleEnabled = false;
          audioVisualizerEnabled = false;
          audioScrollMode = "volume";
          audioWheelScrollAmount = 5;
          clockCompactMode = false;
          focusedWindowCompactMode = false;
          runningAppsCompactMode = true;
          barMaxVisibleApps = 0;
          barMaxVisibleRunningApps = 0;
          barShowOverflowBadge = true;
          appsDockHideIndicators = false;
          appsDockColorizeActive = false;
          appsDockActiveColorMode = "primary";
          appsDockEnlargeOnHover = false;
          appsDockEnlargePercentage = 125;
          appsDockIconSizePercentage = 100;
          keyboardLayoutNameCompactMode = false;
          runningAppsCurrentWorkspace = true;
          runningAppsGroupByApp = false;
          runningAppsCurrentMonitor = false;
          appIdSubstitutions = [ ];
          centeringMode = "index";
          clockDateFormat = "dddd, MMMM d";
          lockDateFormat = "";
          greeterRememberLastSession = true;
          greeterRememberLastUser = true;
          greeterEnableFprint = false;
          greeterEnableU2f = false;
          greeterWallpaperPath = "";
          mediaSize = 1;
          appLauncherViewMode = "grid";
          spotlightModalViewMode = "list";
          browserPickerViewMode = "grid";
          browserUsageHistory = { };
          appPickerViewMode = "grid";
          filePickerUsageHistory = { };
          sortAppsAlphabetically = true;
          appLauncherGridColumns = 4;
          spotlightCloseNiriOverview = true;
          spotlightSectionViewModes = { };
          appDrawerSectionViewModes = { };
          niriOverviewOverlayEnabled = true;
          dankLauncherV2Size = "compact";
          dankLauncherV2BorderEnabled = false;
          dankLauncherV2BorderThickness = 2;
          dankLauncherV2BorderColor = "primary";
          dankLauncherV2ShowFooter = true;
          dankLauncherV2UnloadOnClose = true;
          useAutoLocation = true;
          weatherEnabled = true;
          networkPreference = "wifi";
          iconTheme = "System Default";
          cursorSettings = {
            dwl = {
              cursorHideTimeout = 0;
            };
            hyprland = {
              hideOnKeyPress = false;
              hideOnTouch = false;
              inactiveTimeout = 0;
            };
            niri = {
              hideAfterInactiveMs = 0;
              hideWhenTyping = false;
            };
            size = 24;
            theme = "System Default";
          };
          launcherLogoMode = "compositor";
          launcherLogoCustomPath = "";
          launcherLogoColorOverride = "primary";
          launcherLogoColorInvertOnMode = false;
          launcherLogoBrightness = 0.5;
          launcherLogoContrast = 1;
          launcherLogoSizeOffset = 7;
          fontFamily = "Inter";
          monoFontFamily = "Maple Mono NL NF";
          fontWeight = 400;
          fontScale = 1;
          notepadUseMonospace = true;
          notepadFontFamily = "";
          notepadFontSize = 14;
          notepadShowLineNumbers = false;
          notepadTransparencyOverride = -1;
          notepadLastCustomTransparency = 0.7;
          soundsEnabled = true;
          useSystemSoundTheme = false;
          soundNewNotification = true;
          soundVolumeChanged = true;
          soundPluggedIn = true;
          acMonitorTimeout = 300;
          acLockTimeout = 1800;
          acSuspendTimeout = 0;
          acSuspendBehavior = 0;
          acProfileName = "";
          batteryMonitorTimeout = 0;
          batteryLockTimeout = 0;
          batterySuspendTimeout = 0;
          batterySuspendBehavior = 0;
          batteryProfileName = "";
          batteryChargeLimit = 100;
          lockBeforeSuspend = false;
          loginctlLockIntegration = true;
          fadeToLockEnabled = true;
          fadeToLockGracePeriod = 5;
          fadeToDpmsEnabled = true;
          fadeToDpmsGracePeriod = 5;
          launchPrefix = "runapp";
          brightnessDevicePins = { };
          wifiNetworkPins = { };
          bluetoothDevicePins = { };
          audioInputDevicePins = { };
          audioOutputDevicePins = { };
          gtkThemingEnabled = false;
          qtThemingEnabled = false;
          syncModeWithPortal = true;
          terminalsAlwaysDark = false;
          muxType = "tmux";
          muxUseCustomCommand = false;
          muxCustomCommand = "";
          muxSessionFilter = "";
          runDmsMatugenTemplates = true;
          matugenTemplateGtk = true;
          matugenTemplateNiri = true;
          matugenTemplateHyprland = true;
          matugenTemplateMangowc = true;
          matugenTemplateQt5ct = true;
          matugenTemplateQt6ct = true;
          matugenTemplateFirefox = true;
          matugenTemplatePywalfox = true;
          matugenTemplateZenBrowser = true;
          matugenTemplateVesktop = true;
          matugenTemplateEquibop = true;
          matugenTemplateGhostty = true;
          matugenTemplateKitty = true;
          matugenTemplateFoot = true;
          matugenTemplateAlacritty = true;
          matugenTemplateNeovim = false;
          matugenTemplateWezterm = true;
          matugenTemplateDgop = true;
          matugenTemplateKcolorscheme = true;
          matugenTemplateVscode = true;
          matugenTemplateEmacs = true;
          matugenTemplateZed = true;
          showDock = false;
          dockAutoHide = false;
          dockSmartAutoHide = false;
          dockGroupByApp = false;
          dockOpenOnOverview = false;
          dockPosition = 1;
          dockSpacing = 4;
          dockBottomGap = 0;
          dockMargin = 0;
          dockIconSize = 40;
          dockIndicatorStyle = "circle";
          dockBorderEnabled = false;
          dockBorderColor = "surfaceText";
          dockBorderOpacity = 1;
          dockBorderThickness = 1;
          dockIsolateDisplays = false;
          dockLauncherEnabled = false;
          dockLauncherLogoMode = "apps";
          dockLauncherLogoCustomPath = "";
          dockLauncherLogoColorOverride = "";
          dockLauncherLogoSizeOffset = 0;
          dockLauncherLogoBrightness = 0.5;
          dockLauncherLogoContrast = 1;
          dockMaxVisibleApps = 0;
          dockMaxVisibleRunningApps = 0;
          dockShowOverflowBadge = true;
          notificationOverlayEnabled = false;
          notificationPopupShadowEnabled = true;
          notificationPopupPrivacyMode = false;
          modalDarkenBackground = true;
          lockScreenShowPowerActions = true;
          lockScreenShowSystemIcons = true;
          lockScreenShowTime = true;
          lockScreenShowDate = true;
          lockScreenShowProfileImage = true;
          lockScreenShowPasswordField = true;
          lockScreenShowMediaPlayer = true;
          lockScreenPowerOffMonitorsOnLock = false;
          lockAtStartup = false;
          enableFprint = false;
          maxFprintTries = 15;
          enableU2f = false;
          u2fMode = "or";
          lockScreenActiveMonitor = "all";
          lockScreenInactiveColor = "#000000";
          lockScreenNotificationMode = 0;
          hideBrightnessSlider = false;
          notificationTimeoutLow = 5000;
          notificationTimeoutNormal = 5000;
          notificationTimeoutCritical = 0;
          notificationCompactMode = false;
          notificationPopupPosition = 0;
          notificationAnimationSpeed = 1;
          notificationCustomAnimationDuration = 400;
          notificationHistoryEnabled = true;
          notificationHistoryMaxCount = 50;
          notificationHistoryMaxAgeDays = 7;
          notificationHistorySaveLow = true;
          notificationHistorySaveNormal = true;
          notificationHistorySaveCritical = true;
          notificationRules = [ ];
          osdAlwaysShowValue = true;
          osdPosition = 5;
          osdVolumeEnabled = true;
          osdMediaVolumeEnabled = true;
          osdMediaPlaybackEnabled = false;
          osdBrightnessEnabled = true;
          osdIdleInhibitorEnabled = true;
          osdMicMuteEnabled = true;
          osdCapsLockEnabled = true;
          osdPowerProfileEnabled = true;
          osdAudioOutputEnabled = true;
          powerActionConfirm = true;
          powerActionHoldDuration = 0.5;
          powerMenuActions = [
            "reboot"
            "logout"
            "poweroff"
            "lock"
            "suspend"
            "restart"
          ];
          powerMenuDefaultAction = "logout";
          powerMenuGridLayout = true;
          customPowerActionLock = "";
          customPowerActionLogout = "";
          customPowerActionSuspend = "";
          customPowerActionHibernate = "";
          customPowerActionReboot = "";
          customPowerActionPowerOff = "";
          updaterHideWidget = false;
          updaterUseCustomCommand = false;
          updaterCustomCommand = "";
          updaterTerminalAdditionalParams = "";
          displayNameMode = "model";
          screenPreferences = {
            wallpaper = [
              "all"
            ];
          };
          showOnLastDisplay = { };
          niriOutputSettings = { };
          hyprlandOutputSettings = { };
          displayProfiles = { };
          activeDisplayProfile = { };
          displayProfileAutoSelect = false;
          displayShowDisconnected = false;
          displaySnapToEdge = true;
          barConfigs = [
            {
              autoHide = false;
              autoHideDelay = 250;
              borderColor = "surfaceText";
              borderEnabled = false;
              borderOpacity = 1;
              borderThickness = 1;
              bottomGap = 0;
              centerWidgets = [
                {
                  enabled = true;
                  id = "workspaceSwitcher";
                }
              ];
              clickThrough = true;
              enabled = true;
              fontScale = 1.0;
              gothCornerRadiusOverride = true;
              gothCornerRadiusValue = 8;
              gothCornersEnabled = false;
              iconScale = 1.2;
              id = "default";
              innerPadding = 4;
              leftWidgets = [
                {
                  enabled = true;
                  id = "launcherButton";
                }
                {
                  enabled = true;
                  id = "music";
                  mediaSize = 1;
                }
                {
                  enabled = true;
                  id = "clock";
                }
                {
                  enabled = true;
                  id = "weather";
                }
              ];
              maximizeDetection = true;
              maximizeWidgetIcons = false;
              maximizeWidgetText = false;
              name = "Main Bar";
              noBackground = false;
              openOnOverview = false;
              popupGapsAuto = true;
              popupGapsManual = 4;
              position = 0;
              removeWidgetPadding = false;
              rightWidgets = [
                {
                  enabled = true;
                  id = "systemTray";
                }
                "clipboard"
                {
                  enabled = true;
                  id = "notificationButton";
                }
                {
                  enabled = true;
                  id = "battery";
                }
                {
                  enabled = true;
                  id = "controlCenterButton";
                  showAudioPercent = false;
                  showBatteryIcon = false;
                  showBrightnessIcon = false;
                  showBrightnessPercent = false;
                  showMicIcon = false;
                }
              ];
              screenPreferences = [
                "all"
              ];
              scrollEnabled = true;
              scrollXBehavior = "column";
              scrollYBehavior = "workspace";
              shadowColorMode = "text";
              shadowCustomColor = "#000000";
              shadowIntensity = 0;
              shadowOpacity = 60;
              showOnLastDisplay = true;
              showOnWindowsOpen = false;
              spacing = 4;
              squareCorners = false;
              transparency = 0.8;
              visible = true;
              widgetOutlineColor = "primary";
              widgetOutlineEnabled = false;
              widgetOutlineOpacity = 1;
              widgetOutlineThickness = 1;
              widgetPadding = 8;
              widgetTransparency = 1;
            }
          ];
          desktopClockEnabled = false;
          desktopClockStyle = "analog";
          desktopClockTransparency = 0.8;
          desktopClockColorMode = "primary";
          desktopClockCustomColor = {
            r = 1;
            g = 1;
            b = 1;
            a = 1;
            hsvHue = -1;
            hsvSaturation = 0;
            hsvValue = 1;
            hslHue = -1;
            hslSaturation = 0;
            hslLightness = 1;
            valid = true;
          };
          desktopClockShowDate = true;
          desktopClockShowAnalogNumbers = false;
          desktopClockShowAnalogSeconds = true;
          desktopClockX = -1;
          desktopClockY = -1;
          desktopClockWidth = 280;
          desktopClockHeight = 180;
          desktopClockDisplayPreferences = [
            "all"
          ];
          systemMonitorEnabled = false;
          systemMonitorShowHeader = true;
          systemMonitorTransparency = 0.8;
          systemMonitorColorMode = "primary";
          systemMonitorCustomColor = {
            r = 1;
            g = 1;
            b = 1;
            a = 1;
            hsvHue = -1;
            hsvSaturation = 0;
            hsvValue = 1;
            hslHue = -1;
            hslSaturation = 0;
            hslLightness = 1;
            valid = true;
          };
          systemMonitorShowCpu = true;
          systemMonitorShowCpuGraph = true;
          systemMonitorShowCpuTemp = true;
          systemMonitorShowGpuTemp = false;
          systemMonitorGpuPciId = "";
          systemMonitorShowMemory = true;
          systemMonitorShowMemoryGraph = true;
          systemMonitorShowNetwork = true;
          systemMonitorShowNetworkGraph = true;
          systemMonitorShowDisk = true;
          systemMonitorShowTopProcesses = false;
          systemMonitorTopProcessCount = 3;
          systemMonitorTopProcessSortBy = "cpu";
          systemMonitorGraphInterval = 60;
          systemMonitorLayoutMode = "auto";
          systemMonitorX = -1;
          systemMonitorY = -1;
          systemMonitorWidth = 320;
          systemMonitorHeight = 480;
          systemMonitorDisplayPreferences = [
            "all"
          ];
          systemMonitorVariants = [ ];
          desktopWidgetPositions = { };
          desktopWidgetGridSettings = { };
          desktopWidgetInstances = [ ];
          desktopWidgetGroups = [ ];
          builtInPluginSettings = {
            dms_settings_search = {
              trigger = "?";
            };
          };
          clipboardEnterToPaste = true;
          launcherPluginVisibility = { };
          launcherPluginOrder = [ ];
          configVersion = 5;
        };
        session = {
          wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/96740776_p5.jpg";
        };
      };
    };
}
