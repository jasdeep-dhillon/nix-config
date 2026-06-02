{ inputs, ... }:
{
  flake.nixosModules.theme =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      environment.systemPackages = with pkgs; [
        kdePackages.breeze
        kdePackages.breeze.qt5
        kdePackages.breeze-icons
        adwaita-icon-theme
        adwaita-icon-theme-legacy
        morewaita-icon-theme
      ];
    };
  flake.homeModules.theme =
    { pkgs, lib, ... }:
    let 
      moga-cursor = pkgs.stdenvNoCC.mkDerivation {
        name = "Moga-Cursor";
        src = ../cursor-theme;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/icons/Moga-Cursor
          cp -r * $out/share/icons/Moga-Cursor
          runHook postInstall
        '';
      };
    in
    {
      imports = [ inputs.stylix.homeModules.stylix ];
      home.file."Pictures/Wallpapers".source = ../wallpapers;

      xdg.configFile.dolphinrc.source = (pkgs.formats.ini { }).generate "dolphinrc" {
        ContextMenu = {
          ShowOpenInNewWindow = false;
          ShowOpenTerminal = false;
          ShowSortBy = false;
          ShowViewMode = false;
        };
        General = {
          BrowseThroughArchives = true;
          DynamicView = true;
          GlobalViewProps = false;
          OpenNewTabAfterLastTab = true;
          ShowFullPath = true;
          ShowToolTips = true;
          ShowZoomSlider = true;
          UseTabForSwitchingSplitView = true;
          Version = 202;
          ViewPropsTimestamp = "2025,12,30,23,6,30.167";
        };
        MainWindow = {
          MenuBar = "Disabled";
        };
        UiSettings = {
          ColorScheme = "*";
        };
        PreviewSettings = {
          Plugins = "appimagethumbnail,audiothumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,opendocumentthumbnail,svgthumbnail,textthumbnail";
        };
      };
      xdg.configFile.kdeglobals.source = (pkgs.formats.ini { }).generate "kdeglobals" {
        "ColorEffects:Disabled" = {
          ChangeSelectionColor = "";
          Color = "";
          ColorAmount = 0;
          ColorEffect = 0;
          ContrastAmount = 0.500000;
          ContrastEffect = 1;
          Enable = "";
          IntensityAmount = 0;
          IntensityEffect = 0;
        };
        "ColorEffects:Inactive" = {
          ChangeSelectionColor = "";
          Color = "";
          ColorAmount = 0;
          ColorEffect = 0;
          ContrastAmount = 0.500000;
          ContrastEffect = 1;
          Enable = "";
          IntensityAmount = 0;
          IntensityEffect = 0;
        };
        "Colors:Button" = {
          BackgroundAlternate = "111,86,173";
          BackgroundNormal = "30,30,46";
          DecorationFocus = "146,110,228";
          DecorationHover = "146,110,228";
          ForegroundActive = "146,110,228";
          ForegroundInactive = "205,214,244";
          ForegroundLink = "209,199,242";
          ForegroundNegative = "243,139,168";
          ForegroundNeutral = "137,180,250";
          ForegroundNormal = "205,214,244";
          ForegroundPositive = "166,227,161";
          ForegroundVisited = "205,214,244";
        };
        "Colors:Complementary" = {
          BackgroundAlternate = "49,50,68";
          BackgroundNormal = "30,30,46";
          DecorationFocus = "146,110,228";
          DecorationHover = "146,110,228";
          ForegroundActive = "146,110,228";
          ForegroundInactive = "205,214,244";
          ForegroundLink = "209,199,242";
          ForegroundNegative = "243,139,168";
          ForegroundNeutral = "137,180,250";
          ForegroundNormal = "205,214,244";
          ForegroundPositive = "166,227,161";
          ForegroundVisited = "205,214,244";
        };
        "Colors:Tooltip" = {
          BackgroundAlternate = "49,50,68";
          BackgroundNormal = "30,30,46";
          DecorationFocus = "146,110,228";
          DecorationHover = "146,110,228";
          ForegroundActive = "146,110,228";
          ForegroundInactive = "205,214,244";
          ForegroundLink = "209,199,242";
          ForegroundNegative = "243,139,168";
          ForegroundNeutral = "137,180,250";
          ForegroundNormal = "205,214,244";
          ForegroundPositive = "166,227,161";
          ForegroundVisited = "205,214,244";
        };
        "Colors:View" = {
          BackgroundAlternate = "49,50,68";
          BackgroundNormal = "30,30,46";
          DecorationFocus = "146,110,228";
          DecorationHover = "146,110,228";
          ForegroundActive = "146,110,228";
          ForegroundInactive = "205,214,244";
          ForegroundLink = "209,199,242";
          ForegroundNegative = "243,139,168";
          ForegroundNeutral = "137,180,250";
          ForegroundNormal = "205,214,244";
          ForegroundPositive = "166,227,161";
          ForegroundVisited = "205,214,244";
        };
        "Colors:Window" = {
          BackgroundAlternate = "49,50,68";
          BackgroundNormal = "30,30,46";
          DecorationFocus = "146,110,228";
          DecorationHover = "146,110,228";
          ForegroundActive = "146,110,228";
          ForegroundInactive = "205,214,244";
          ForegroundLink = "209,199,242";
          ForegroundNegative = "243,139,168";
          ForegroundNeutral = "137,180,250";
          ForegroundNormal = "205,214,244";
          ForegroundPositive = "166,227,161";
          ForegroundVisited = "205,214,244";
        };
        WM = {
          activeBackground = "30,30,46";
          activeBlend = "249,226,175";
          activeForeground = "205,214,244";
          frame = "108,83,166";
          inactiveBackground = "30,30,46";
          inactiveBlend = "108,112,134";
          inactiveForeground = "205,214,244";
          inactiveFrame = "12,12,12";
        };
      };

      home.packages = with pkgs; [
        kdePackages.qt6ct
        libsForQt5.qt5ct
      ];
      stylix = {
        enable = true;
        enableReleaseChecks = false;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        targets.dank-material-shell.enable = false;
        targets.qt = {
          enable = false;
          platform = "qtct";
          standardDialogs = "xdgdesktopportal";
        };
        icons = {
          enable = true;
          dark = "Adwaita";
          light = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        fonts = {
          sizes = {
            applications = 12;
            desktop = 12;
            terminal = 12;
          };
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
          monospace = {
            package = pkgs.maple-mono.NF;
            name = "Maple Mono NL NF";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };
      };

      qt = {
        enable = true;
        platformTheme = {
          name = "qtct";
          package = pkgs.catppuccin-qt5ct;
        };
        qt5ctSettings = {
          Appearance = {
            style = "Breeze";
            icon_theme = "breeze-dark";
            standard_dialogs = "xdgdesktopportal";
            color_scheme_path = "${pkgs.catppuccin-qt5ct}/share/qt5ct/colors/catppuccin-mocha-lavender.conf";
            custom_palette = true;
          };
          Fonts = {
            fixed = ''"Maple Mono NF,12"'';
            general = ''"Inter,12"'';
          };
        };
        qt6ctSettings = {
          Appearance = {
            style = "Breeze";
            icon_theme = "breeze-dark";
            standard_dialogs = "xdgdesktopportal";
            color_scheme_path = "${pkgs.catppuccin-qt5ct}/share/qt6ct/colors/catppuccin-mocha-lavender.conf";
            custom_palette = true;
          };
          Fonts = {
            fixed = ''"Maple Mono NF,12"'';
            general = ''"Inter,12"'';
          };
        };
      };

      home.pointerCursor = lib.mkDefault {
        enable = true;
        name = "Moga-Cursor";
        package = moga-cursor;
        size = 20;
        hyprcursor = {
          enable = true;
          size = 20;
        };
        gtk.enable = true;
      };

      dconf = {
        settings = {
          "org/gnome/desktop/wm/preferences" = {
            button-layout = "icon: close";
          };
        };
      };
    };
}
