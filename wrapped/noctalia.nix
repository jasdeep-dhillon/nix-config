{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        enableDumpScript = true;
        settings = {
          appLauncher = {
            autoPasteClipboard = true;
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWrapText = true;
            customLaunchPrefix = "runapp";
            customLaunchPrefixEnabled = true;
            density = "compact";
            enableClipPreview = true;
            enableClipboardChips = true;
            enableClipboardHistory = true;
            enableClipboardSmartIcons = true;
            enableSessionSearch = true;
            enableSettingsSearch = true;
            enableWindowsSearch = false;
            iconMode = "native";
            ignoreMouseInput = false;
            overviewLayer = true;
            pinnedApps = [
              "org.kde.dolphin"
              "helium"
              "kitty"
              "vesktop"
              "dev.zed.Zed"
              "chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Default"
              "chrome-magkoliahgffibhgfkmoealggombgknl-Default"
              "Windows"
              "steam"
              "xyz.TOS.Nero"
              "bitwarden"
              "net.nokyan.Resources"
              "Ryujinx"
              "chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default"
              "LocalSend"
              "faugus-launcher"
              "Overwatch 2"
            ];
            position = "follow_bar";
            screenshotAnnotationTool = "";
            showCategories = true;
            showIconBackground = false;
            sortByMostUsed = false;
            terminalCommand = "kitty -e";
            viewMode = "grid";
          };
          audio = {
            mprisBlacklist = [ ];
            preferredPlayer = "";
            spectrumFrameRate = 30;
            spectrumMirrored = true;
            visualizerType = "none";
            volumeFeedback = true;
            volumeFeedbackSoundFile = "";
            volumeOverdrive = true;
            volumeStep = 2;
          };
          bar = {
            autoHideDelay = 500;
            autoShowDelay = 150;
            backgroundOpacity = 0.75;
            barType = "floating";
            capsuleColorKey = "none";
            capsuleOpacity = 0.75;
            contentPadding = 4;
            density = "default";
            displayMode = "always_visible";
            enableExclusionZoneInset = true;
            fontScale = 1;
            frameRadius = 9;
            frameThickness = 4;
            hideOnOverview = false;
            marginHorizontal = 2;
            marginVertical = 2;
            middleClickAction = "launcherPanel";
            middleClickCommand = "";
            middleClickFollowMouse = true;
            monitors = [ ];
            mouseWheelAction = "workspace";
            mouseWheelWrap = true;
            outerCorners = true;
            position = "top";
            reverseScroll = false;
            rightClickAction = "controlCenter";
            rightClickCommand = "";
            rightClickFollowMouse = true;
            screenOverrides = [ ];
            showCapsule = true;
            showOnWorkspaceSwitch = true;
            showOutline = false;
            useSeparateOpacity = false;
            widgetSpacing = 4;
            widgets = {
              center = [
                {
                  colorizeSystemIcon = "none";
                  customIconPath = "";
                  enableColorization = true;
                  icon = "atom-2";
                  iconColor = "primary";
                  id = "Launcher";
                  useDistroLogo = false;
                }
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  emptyColor = "secondary";
                  enableScrollWheel = true;
                  focusedColor = "primary";
                  followFocusedScreen = false;
                  fontWeight = "bold";
                  groupedBorderOpacity = 0.3;
                  hideUnoccupied = false;
                  iconScale = 0.8;
                  id = "Workspace";
                  labelMode = "index+name";
                  occupiedColor = "tertiary";
                  pillSize = 0.6;
                  showApplications = true;
                  showApplicationsHover = false;
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = false;
                  unfocusedIconsOpacity = 0.5;
                }
              ];
              left = [
                {
                  colorizeDistroLogo = false;
                  colorizeSystemIcon = "primary";
                  customIconPath = "";
                  enableColorization = true;
                  icon = "niri";
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  compactMode = true;
                  hideMode = "visible";
                  hideWhenIdle = false;
                  id = "MediaMini";
                  maxWidth = 200;
                  panelShowAlbumArt = true;
                  scrollingMode = "hover";
                  showAlbumArt = true;
                  showArtistFirst = false;
                  showProgressRing = true;
                  showVisualizer = false;
                  textColor = "none";
                  useFixedWidth = false;
                  visualizerType = "wave";
                }
                {
                  clockColor = "none";
                  customFont = "Inter";
                  formatHorizontal = "hh:mm ap ddd, dd MMM";
                  formatVertical = "hh mm ap - ddd dd MMM";
                  id = "Clock";
                  tooltipFormat = "h:mm AP ddd, MMM dd";
                  useCustomFont = false;
                }
              ];
              right = [
                {
                  blacklist = [ ];
                  chevronColor = "none";
                  colorizeIcons = false;
                  drawerEnabled = false;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [ ];
                }
                {
                  defaultSettings = {
                    activeColor = "primary";
                    enableToast = true;
                    hideInactive = false;
                    iconSpacing = 4;
                    inactiveColor = "none";
                    micFilterRegex = "";
                    removeMargins = false;
                  };
                  id = "plugin:privacy-indicator";
                }
                {
                  displayMode = "alwaysShow";
                  iconColor = "none";
                  id = "VPN";
                  textColor = "none";
                }
                {
                  applyToAllMonitors = false;
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Brightness";
                  textColor = "none";
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Volume";
                  middleClickCommand = "";
                  textColor = "none";
                }
                {
                  deviceNativePath = "__default__";
                  displayMode = "icon-always";
                  hideIfIdle = false;
                  hideIfNotDetected = false;
                  id = "Battery";
                  showNoctaliaPerformance = true;
                  showPowerProfiles = true;
                }
                {
                  hideWhenZero = false;
                  hideWhenZeroUnread = false;
                  iconColor = "none";
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                  unreadBadgeColor = "primary";
                }
                {
                  iconColor = "error";
                  id = "SessionMenu";
                }
              ];
            };
          };
          brightness = {
            backlightDeviceMappings = [ ];
            brightnessStep = 5;
            enableDdcSupport = true;
            enforceMinimum = true;
          };
          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = false;
                id = "weather-card";
              }
            ];
          };
          colorSchemes = {
            darkMode = true;
            generationMethod = "rainbow";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            monitorForColors = "DP-5";
            predefinedScheme = "Catppuccin Lavender";
            schedulingMode = "off";
            syncGsettings = true;
            useWallpaperColors = false;
          };
          controlCenter = {
            cards = [
              {
                enabled = false;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "profile-card";
              }
            ];
            diskPath = "/";
            position = "close_to_bar_button";
            shortcuts = {
              left = [
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "DarkMode"; }
                { id = "AirplaneMode"; }
              ];
              right = [
                { id = "KeepAwake"; }
                {
                  enableOnStateLogic = false;
                  generalTooltipText = "Boot Windows";
                  icon = "brand-windows-filled";
                  id = "CustomButton";
                  onClicked = "pkexec nu -c \"bootctl set-oneshot auto-windows; reboot\"";
                  onMiddleClicked = "";
                  onRightClicked = "";
                  showExecTooltip = true;
                  stateChecksJson = "[]";
                }
                {
                  enableOnStateLogic = true;
                  generalTooltipText = "Toggle Laptop Display";
                  icon = "device-laptop-off";
                  id = "CustomButton";
                  onClicked = "if ! niri msg --json outputs | jq -e '.[\"eDP-1\"].current_mode' >/dev/null 2>&1; then\n    nu -c \"niri msg output 'BOE 0x0A9B Unknown' on\"\nelse\n    nu -c \"niri msg output 'BOE 0x0A9B Unknown' off\"\nfi";
                  onMiddleClicked = "";
                  onRightClicked = "";
                  showExecTooltip = true;
                  stateChecksJson = "[{\"command\":\"niri msg --json outputs | jq -e '.[\\\"eDP-1\\\"].current_mode'\",\"icon\":\"device-laptop\"}]";
                }
                { id = "NoctaliaPerformance"; }
              ];
            };
          };
          desktopWidgets = {
            enabled = false;
            gridSnap = false;
            gridSnapScale = false;
            monitorWidgets = [
              {
                name = "DP-5";
                widgets = [ ];
              }
              {
                name = "DP-1";
                widgets = [ ];
              }
            ];
            overviewEnabled = true;
          };
          dock = {
            animationSpeed = 1;
            backgroundOpacity = 1;
            colorizeIcons = true;
            deadOpacity = 0.35;
            displayMode = "always_visible";
            dockType = "floating";
            enabled = false;
            floatingRatio = 0;
            groupApps = false;
            groupClickAction = "cycle";
            groupContextMenuMode = "extended";
            groupIndicatorStyle = "dots";
            inactiveIndicators = true;
            indicatorColor = "primary";
            indicatorOpacity = 0.6;
            indicatorThickness = 3;
            launcherIcon = "";
            launcherIconColor = "none";
            launcherPosition = "end";
            launcherUseDistroLogo = false;
            monitors = [ ];
            onlySameOutput = true;
            pinnedApps = [ "org.kde.dolphin" ];
            pinnedStatic = true;
            position = "bottom";
            showDockIndicator = false;
            showLauncherIcon = false;
            sitOnFrame = false;
            size = 0.35;
          };
          general = {
            allowPanelsOnScreenWithoutBar = true;
            allowPasswordWithFprintd = false;
            animationDisabled = false;
            animationSpeed = 2;
            autoStartAuth = false;
            avatarImage = ../avatar.jpg;
            boxRadiusRatio = 1;
            clockFormat = "hh\\nmm";
            clockStyle = "custom";
            compactLockScreen = false;
            dimmerOpacity = 0.25;
            enableBlurBehind = true;
            enableLockScreenCountdown = true;
            enableLockScreenMediaControls = false;
            enableShadows = false;
            forceBlackScreenCorners = true;
            iRadiusRatio = 0.6;
            keybinds = {
              keyDown = [ "Down" ];
              keyEnter = [
                "Return"
                "Enter"
              ];
              keyEscape = [ "Esc" ];
              keyLeft = [ "Left" ];
              keyRemove = [ "Del" ];
              keyRight = [ "Right" ];
              keyUp = [ "Up" ];
            };
            language = "";
            lockOnSuspend = true;
            lockScreenAnimations = false;
            lockScreenBlur = 0.7;
            lockScreenCountdownDuration = 3000;
            lockScreenMonitors = [ ];
            lockScreenTint = 0.1;
            passwordChars = true;
            radiusRatio = 0.48;
            reverseScroll = false;
            scaleRatio = 0.9;
            screenRadiusRatio = 0.35;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            showChangelogOnStartup = true;
            showHibernateOnLockScreen = true;
            showScreenCorners = true;
            showSessionButtonsOnLockScreen = true;
            smoothScrollEnabled = true;
            telemetryEnabled = true;
          };
          hooks = {
            colorGeneration = "";
            darkModeChange = "";
            enabled = true;
            performanceModeDisabled = "";
            performanceModeEnabled = "";
            screenLock = "";
            screenUnlock = "";
            session = "pkill helium; ps | where name == electron | get pid | each {kill -9 $in}; pkill -9 steam";
            startup = "";
            wallpaperChange = "";
          };
          idle = {
            customCommands = "[]";
            enabled = true;
            fadeDuration = 5;
            lockCommand = "";
            lockTimeout = 600;
            resumeLockCommand = "";
            resumeScreenOffCommand = "";
            resumeSuspendCommand = "";
            screenOffCommand = "";
            screenOffTimeout = 600;
            suspendCommand = "";
            suspendTimeout = 1800;
          };
          location = {
            analogClockInCalendar = false;
            autoLocate = true;
            firstDayOfWeek = 1;
            hideWeatherCityName = false;
            hideWeatherTimezone = false;
            name = "Hamilton";
            showCalendarEvents = true;
            showCalendarWeather = true;
            showWeekNumberInCalendar = false;
            use12hourFormat = true;
            useFahrenheit = false;
            weatherEnabled = true;
            weatherShowEffects = true;
            weatherTaliaMascotAlways = false;
          };
          network = {
            bluetoothAutoConnect = false;
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = true;
            bluetoothRssiPollIntervalMs = 10000;
            bluetoothRssiPollingEnabled = false;
            disableDiscoverability = true;
            networkPanelView = "wifi";
            wifiDetailsViewMode = "list";
          };
          nightLight = {
            autoSchedule = true;
            dayTemp = "6500";
            enabled = false;
            forced = false;
            manualSunrise = "06:30";
            manualSunset = "18:30";
            nightTemp = "4000";
          };
          noctaliaPerformance = {
            disableDesktopWidgets = true;
            disableWallpaper = true;
          };
          notifications = {
            backgroundOpacity = 0.75;
            clearDismissed = true;
            criticalUrgencyDuration = 15;
            density = "default";
            enableBatteryToast = true;
            enableKeyboardLayoutToast = true;
            enableMarkdown = true;
            enableMediaToast = false;
            enabled = true;
            location = "top_right";
            lowUrgencyDuration = 3;
            monitors = [ ];
            normalUrgencyDuration = 8;
            overlayLayer = true;
            respectExpireTimeout = false;
            saveToHistory = {
              critical = true;
              low = true;
              normal = true;
            };
            sounds = {
              criticalSoundFile = "";
              enabled = true;
              excludedApps = "discord,firefox,chrome,chromium,edge,vesktop";
              lowSoundFile = "";
              normalSoundFile = "";
              separateSounds = false;
              volume = 0.5;
            };
          };
          osd = {
            autoHideMs = 1000;
            backgroundOpacity = 0.75;
            enabled = true;
            enabledTypes = [
              0
              1
              2
              3
            ];
            location = "bottom";
            monitors = [ ];
            overlayLayer = true;
          };
          plugins = {
            autoUpdate = false;
            notifyUpdates = true;
          };
          sessionMenu = {
            countdownDuration = 3000;
            enableCountdown = true;
            largeButtonsLayout = "grid";
            largeButtonsStyle = true;
            position = "bottom_center";
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "1";
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "2";
              }
              {
                action = "rebootToUefi";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "3";
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "4";
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "5";
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "6";
              }
              {
                action = "userspaceReboot";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
            ];
            showHeader = true;
            showKeybinds = true;
          };
          settingsVersion = 59;
          systemMonitor = {
            batteryCriticalThreshold = 5;
            batteryWarningThreshold = 20;
            cpuCriticalThreshold = 90;
            cpuWarningThreshold = 80;
            criticalColor = "#f38ba8";
            diskAvailCriticalThreshold = 10;
            diskAvailWarningThreshold = 20;
            diskCriticalThreshold = 90;
            diskWarningThreshold = 80;
            enableDgpuMonitoring = true;
            externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
            gpuCriticalThreshold = 90;
            gpuWarningThreshold = 80;
            memCriticalThreshold = 90;
            memWarningThreshold = 80;
            swapCriticalThreshold = 90;
            swapWarningThreshold = 80;
            tempCriticalThreshold = 90;
            tempWarningThreshold = 80;
            useCustomColors = false;
            warningColor = "#c6a0f6";
          };
          templates = {
            activeTemplates = [
              {
                enabled = true;
                id = "steam";
              }
            ];
            enableUserTheming = false;
          };
          ui = {
            boxBorderEnabled = false;
            fontDefault = "Inter";
            fontDefaultScale = 1;
            fontFixed = "Maple Mono NF";
            fontFixedScale = 1;
            panelBackgroundOpacity = 0.75;
            panelsAttachedToBar = true;
            scrollbarAlwaysVisible = true;
            settingsPanelMode = "window";
            settingsPanelSideBarCardStyle = false;
            tooltipsEnabled = false;
            translucentWidgets = true;
          };
          wallpaper = {
            automationEnabled = false;
            directory = "~/Pictures/Wallpapers";
            enableMultiMonitorDirectories = false;
            enabled = true;
            favorites = [ ];
            fillColor = "#000000";
            fillMode = "crop";
            hideWallpaperFilenames = true;
            linkLightAndDarkWallpapers = true;
            monitorDirectories = [
              {
                directory = "~/Pictures/Wallpapers";
                name = "DP-5";
                wallpaper = "";
              }
              {
                directory = "~/Pictures/Wallpapers";
                name = "eDP-1";
                wallpaper = "";
              }
              {
                directory = "~/Pictures/Wallpapers";
                name = "DP-1";
                wallpaper = "";
              }
            ];
            overviewBlur = 0.55;
            overviewEnabled = true;
            overviewTint = 0.6;
            panelPosition = "follow_bar";
            randomIntervalSec = 300;
            setWallpaperOnAllMonitors = true;
            showHiddenFiles = false;
            skipStartupTransition = true;
            solidColor = "#1a1a2e";
            sortOrder = "name";
            transitionDuration = 500;
            transitionEdgeSmoothness = 0.05;
            transitionType = [ "disc" ];
            useOriginalImages = false;
            useSolidColor = false;
            useWallhaven = false;
            viewMode = "single";
            wallhavenApiKey = "";
            wallhavenCategories = "111";
            wallhavenOrder = "desc";
            wallhavenPurity = "100";
            wallhavenQuery = "";
            wallhavenRatios = "";
            wallhavenResolutionHeight = "";
            wallhavenResolutionMode = "atleast";
            wallhavenResolutionWidth = "";
            wallhavenSorting = "relevance";
            wallpaperChangeMode = "random";
          };
        };
        colors = {
          mError = "#f38ba8";
          mHover = "#c6a0f6";
          mOnError = "#11111b";
          mOnHover = "#11111b";
          mOnPrimary = "#11111b";
          mOnSecondary = "#11111b";
          mOnSurface = "#cdd6f4";
          mOnSurfaceVariant = "#a3b4eb";
          mOnTertiary = "#11111b";
          mOutline = "#4c4f69";
          mPrimary = "#b4befe";
          mSecondary = "#f5bde6";
          mShadow = "#11111b";
          mSurface = "#070722";
          mSurfaceVariant = "#1e1e2e";
          mTertiary = "#c6a0f6";
        };
        plugins = {
          sources = [
            {
              enabled = true;
              name = "Noctalia Plugins";
              url = "https=//github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            privacy-indicator = {
              enabled = true;
              sourceUrl = "https=//github.com/noctalia-dev/noctalia-plugins";
            };
            unicode-picker = {
              enabled = true;
              sourceUrl = "https=//github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 2;
        };
        pluginSettings = {
          privacy-indicator = {
            hideInactive = true;
            enableToast = true;
            removeMargins = false;
            iconSpacing = 4;
            activeColor = "primary";
            inactiveColor = "none";
            micFilterRegex = "";
          };
        };
        preInstalledPlugins = {
          privacy-indicator.src = "${inputs.noctalia-plugins.outPath}/privacy-indicator";
          unicode-picker.src = "${inputs.noctalia-plugins.outPath}/unicode-picker";
        };
      };
    };
}
