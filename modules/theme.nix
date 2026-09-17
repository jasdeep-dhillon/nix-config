{ self, ... }:
{
  flake.nixosModules.theme =
    { pkgs, ... }:
    {
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
    {
      home.file."Pictures/Wallpapers" = {
        source = ../wallpapers;
        recursive = true;
      };

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

      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };
        gtk3.extraCss = ''
          @define-color blue-1 #89b4fa;
          @define-color blue-2 #74c7ec;
          @define-color blue-3 #89dceb;
          @define-color blue-4 #94e2d5;
          @define-color blue-5 #b4befe;
          @define-color green-1 #a6e3a1;
          @define-color green-2 #94e2d5;
          @define-color green-3 #89dceb;
          @define-color green-4 #74c7ec;
          @define-color green-5 #89b4fa;
          @define-color yellow-1 #f9e2af;
          @define-color yellow-2 #fab387;
          @define-color yellow-3 #f9e2af;
          @define-color yellow-4 #f38ba8;
          @define-color yellow-5 #eba0ac;
          @define-color orange-1 #fab387;
          @define-color orange-2 #f38ba8;
          @define-color orange-3 #eba0ac;
          @define-color orange-4 #f9e2af;
          @define-color orange-5 #a6e3a1;
          @define-color red-1 #f38ba8;
          @define-color red-2 #eba0ac;
          @define-color red-3 #f5c2e7;
          @define-color red-4 #f2cdcd;
          @define-color red-5 #f5e0dc;
          @define-color purple-1 #cba6f7;
          @define-color purple-2 #b4befe;
          @define-color purple-3 #f5c2e7;
          @define-color purple-4 #f2cdcd;
          @define-color purple-5 #f5e0dc;
          @define-color brown-1 #585b70;
          @define-color brown-2 #6c7086;
          @define-color brown-3 #7f849c;
          @define-color brown-4 #9399b2;
          @define-color brown-5 #bac2de;
          @define-color light-1 #cdd6f4;
          @define-color light-2 #a6adc8;
          @define-color light-3 #bac2de;
          @define-color light-4 #89b4fa;
          @define-color light-5 #6c7086;
          @define-color dark-1 #313244;
          @define-color dark-2 #45475a;
          @define-color dark-3 #585b70;
          @define-color dark-4 #181825;
          @define-color dark-5 #11111b;
          @define-color accent-bg-color #b4befe;
          @define-color accent-color #b4befe;
          @define-color accent-fg-color #222222;
          @define-color destructive-bg-color #f38ba8;
          @define-color destructive-color #f38ba8;
          @define-color destructive-fg-color #1e1e2e;
          @define-color success-bg-color #a6e3a1;
          @define-color success-fg-color #1e1e2e;
          @define-color warning-color #f38ba8;
          @define-color warning-bg-color #f38ba8;
          @define-color warning-fg-color #1e1e2e;
          @define-color error-bg-color #f38ba8;
          @define-color error-fg-color #1e1e2e;
          @define-color success-color mix(@success-bg-color,white,0.4);
          @define-color error-color mix(@error-bg-color,white,0.4);
          @define-color window-bg-color #1e1e2e;
          @define-color window-fg-color #cdd6f4;
          @define-color view-bg-color #1e1e2e;
          @define-color view-fg-color #cdd6f4;
          @define-color headerbar-bg-color #181825;
          @define-color headerbar-fg-color #cdd6f4;
          @define-color headerbar-border-color #181825;
          @define-color headerbar-backdrop-color #1e1e2e;
          @define-color headerbar-shade-color rgba(0, 0, 6, 0.36);
          @define-color headerbar-darker-shade-color rgba(0, 0, 12, 0.9);
          @define-color sidebar-bg-color #181825;
          @define-color sidebar-fg-color #cdd6f4;
          @define-color sidebar-backdrop-color #181825;
          @define-color sidebar-shade-color rgba(0, 0, 6, 0.25);
          @define-color sidebar-border-color rgba(0, 0, 6, 0.36);
          @define-color card-bg-color #2f3042;
          @define-color card-fg-color #cdd6f4;
          @define-color card-shade-color rgba(0, 0, 6, 0.36);
          @define-color dialog-bg-color mix(#1e1e2e, black, 0.8);
          @define-color dialog-fg-color #cdd6f4;
          @define-color popover-bg-color mix(#1e1e2e, black, 0.8);
          @define-color popover-fg-color #cdd6f4;
          @define-color popover-shade-color rgba(0, 0, 6, 0.25);
          @define-color thumbnail-bg-color #2f3042;
          @define-color thumbnail-fg-color #cdd6f4;
          @define-color shade-color rgba(0, 0, 6, 0.25);
          @define-color scrollbar-outline-color rgba(0, 0, 12, 0.95);
          @define-color panel-bg-color #1e1e2e;
          @define-color panel-fg-color #cdd6f4;
          @define-color theme-fg-color #cdd6f4;
          @define-color theme-text-color #cdd6f4;
          @define-color theme-bg-color #1e1e2e;
          @define-color theme-base-color #1e1e2e;
          @define-color theme-selected-bg-color @accent-bg-color;
          @define-color theme-selected-fg-color #222222;
          @define-color insensitive-bg-color mix(#1e1e2e,#1e1e2e,0.4);
          @define-color insensitive-fg-color alpha(#cdd6f4,0.5);
          @define-color insensitive-base-color #1e1e2e;
          @define-color theme-unfocused-fg-color mix(#cdd6f4,#1e1e2e,0.5);
          @define-color theme-unfocused-text-color #cdd6f4;
          @define-color theme-unfocused-bg-color #1e1e2e;
          @define-color theme-unfocused-base-color #1e1e2e;
          @define-color theme-unfocused-selected-bg-color @accent-bg-color;
          @define-color theme-unfocused-selected-fg-color #222222;
          @define-color unfocused-insensitive-color mix(mix(#cdd6f4,#1e1e2e,0.5),#1e1e2e,0.5);
          @define-color borders mix(currentColor,#1e1e2e,0.85);
          @define-color unfocused-borders mix(currentColor,#1e1e2e,0.73);
          @define-color warning-color @warning-color;
          @define-color error-color @error-color;
          @define-color success-color @success-color;
          @define-color wm-title shade(#cdd6f4, 1.8);
          @define-color wm-unfocused-title mix(#cdd6f4,#1e1e2e,0.5);
          @define-color wm-highlight black;
          @define-color wm-borders-edge alpha(#cdd6f4,0.07);
          @define-color wm-bg-a shade(#1e1e2e, 1.2);
          @define-color wm-bg-b #1e1e2e;
          @define-color wm-shadow alpha(black, 0.35);
          @define-color wm-border alpha(black, 0.18);
          @define-color wm-button-hover-color-a shade(#1e1e2e, 1.3);
          @define-color wm-button-hover-color-b #1e1e2e;
          @define-color wm-button-active-color-a shade(#1e1e2e, 0.85);
          @define-color wm-button-active-color-b shade(#1e1e2e, 0.89);
          @define-color wm-button-active-color-c shade(#1e1e2e, 0.9);
          @define-color content-view-bg #1e1e2e;
          @define-color text-view-bg shade(#1e1e2e,0.94);


          /* Windows */
          * {
            color: @theme-fg-color;
            background-image: none;
            box-shadow: none;
            text-shadow: none;
          }

          window {
            background-color: @theme-bg-color;
            color: @theme-fg-color;
          }

          .background:not(.nautilus-desktop):not(.desktopwindow) {
            background-color: #1e1e2e;
            color: #cdd6f4;
          }

          .background.nemo-window, .nemo-desktop {
            background-color: transparent;
  	       color: #cdd6f4;
          }

          .nautilus-desktop,
          NautilusWindow.nautilus-desktop {
            background-color: transparent;
          }

          window.desktopwindow {
              background-color: rgba(0, 0, 0, 0);
          }

          window:backdrop {
            color: @theme-unfocused-fg-color;
          }

          .content-view  {
   	        background-color: #1e1e2e;
            }

          iconview {
           	background-color: #1e1e2e;
          }

          iconview > *:hover {
           	background-color: #2f3042;
          }

          decoration {
            box-shadow: 0 3px 8px 1px rgba(0, 0, 0, 0.3), 0 0 0 2px shade(transparent, 0.86);
          }

          /* Headerbar / titlebar */
          headerbar, .titlebar, toolbar {
            background-color: #181825;
            color: #cdd6f4;
            border-color: @borders-color;
            box-shadow: none;
            border-bottom-color: transparent;
          }

          headerbar:backdrop, .titlebar:backdrop {
            background-color: #181825;
            color: mix(#cdd6f4, #181825, 0.5);
          }

          .titlebutton {
            border: none;
           	background-color: #2f3042;
          }

          revealer > box  {
           	background-color: #2f3042;
           	color: #cdd6f4;
           	border: none;
          }


          /* Buttons */
          button:not(.close):not(.minimize):not(.maximize):not(.suggested-action):not(.destructive-action) {
            color: #cdd6f4;
            border-color: @borders;
          }

          button:not(.close):not(.minimize):not(.maximize):not(.suggested-action):not(.destructive-action):not(:checked):not(:hover) {
            background-color: #2f3042;
          }

          button:hover:not(.suggested-action):not(.destructive-action) {
            background-color: shade(#2f3042, 0.85);
          }

          button:disabled {
            background-color: @insensitive-bg-color;
            color: @insensitive-fg-color;
          }

          .close-button {
           	margin: 5px 0 5px 0;
          }

          .suggested-action {
            background-color: @accent-bg-color;
            color: #222222;
          }

          .suggested-action > label {
           	color: #222222;
          }

          .suggested-action:hover {
            background-color: shade(@accent-bg-color, 1.2);
          }


          .destructive-action {
            background-color: #f38ba8;
            border-color: transparent;
            color: #313244;
          }

          .destructive-action > label,
          .destructive-action > image {
            color: #313244;
          }

          .destructive-action:hover {
            background-color: shade(#f38ba8, 0.8);
          }

          .flat {
            background-color: transparent;
            border-color: transparent;
          }

          .flat:hover {
            background-color: alpha(#cdd6f4, 0.08);
          }

          .radio:checked, .radio:active, button:checked {
           	background-color: mix(#2f3042, white, 0.1);
          }

          .frame {
           	border-color: mix(#313244, white, 0.05);
          }

          /* Text entries, spinbuttons, textviews */
          entry, spinbutton, textview, textview text {
            background-color: #1e1e2e;
            color: #cdd6f4;
            border-color: @borders;
          }

          entry:focus, spinbutton:focus, textview:focus {
            border-color: @accent-bg-color;
          }

          entry:disabled, spinbutton:disabled, textview:disabled {
            background-color: @insensitive-base-color;
            color: @insensitive-fg-color;
          }

          spinbutton > entry {
           	background-color: transparent;
                    }

                    /* Menus / popovers / comboboxes */
                    menu, .menu, popover, popover.background {
                      background-color: #1e1e2e;
                      color: #cdd6f4;
                      border-color: transparent;
                    }

                    modelbutton:hover, menuitem:hover {
           	background-color: #2f3042;
           	color: #cdd6f4;
           	box-shadow: none;
          }

          combobox window.background.popup,
          combobox window.background.popup menu {
            background-color: #1e1e2e;
            color: #cdd6f4;
          }

          menubar:backdrop {
           	background-color: #1e1e2e;
          }

          /* Dialogs */
          window.background.dialog, messagedialog, .dialog {
            background-color: var(--popover-bg-color);
            color: var(--popover-fg-color);
          }

          .keycap {
           	background-color: #2f3042;
           	border: none;
           	color: #cdd6f4;
          }

          /* Notebook / tabs */

          notebook {
           	border: none;
           	background-image: none;
          }

          stack {
           	background-color: transparent;
          }

          tab:hover {
           	background-color: #2f3042;
          }

          notebook > header, notebook:disabled > header {
            background-color: #181825;
            border-color: @borders;
          }

          notebook > header tab {
            color: mix(#cdd6f4, #181825, 0.5);
          }

          notebook > header tab:checked {
            background-color: #1e1e2e;
            color: #cdd6f4;
          }

          notebook > header tab:hover {
            color: #cdd6f4;
          }

          tab {
           	background-color: mix(#1e1e2e, #2f3042, 0.5);
           	border: none;
          }

          tab:checked {
           	background-color: mix(@accent-bg-color, #2f3042, 0.9);
          }

          /* Scrollbars */
          scrollbar {
           	background-color: #181825;
           	border: none;
          }

          scrollbar slider {
            background-color: mix(#cdd6f4, #1e1e2e, 0.4);
            min-width: 6px;
            min-height: 6px;
          }

          scrollbar slider:hover {
            background-color: @accent-bg-color;
          }

          scrollbar trough {
            background-color: transparent;
          }

          .floating-bar {
           	background-color: #2f3042;
           	border: none;
          }

          /* Lists */
          treeview, list, listview {
            color: #cdd6f4;
           	background-color: mix(#1e1e2e, black, 0.1);
          }

          treeview:selected, row:selected, list row:selected {
            background-color: #2f3042;
            color: #cdd6f4;
          }

          treeview.view.cell:selected:focus label,
          row:selected label {
            color: #cdd6f4;
          }

          /* Sidebars */
          .sidebar, list.sidebar, .navigation-sidebar {
            background-color: #181825;
            color: #cdd6f4;
            border-color: #313244;
          }

          .sidebar:backdrop, list.sidebar:backdrop {
            background-color: var(--sidebar-bg-color);
          }

          .sidebar row:selected, .navigation-sidebar row:selected {
            background-color: #2f3042;
            color: #cdd6f4;
          }

          /* Cards */
          .card, frame.card {
            background-color: #2f3042;
            color: #cdd6f4;
          }

          viewport {
            background-color: #1e1e2e;
            color: #cdd6f4;
          }

          /* Checkbuttons / radios / switches */
          checkbutton check, radiobutton radio {
            background-color: #1e1e2e;
            border-color: @borders;
          }

          checkbutton check:checked, radiobutton radio:checked {
            background-color: @accent-bg-color;
            border-color: @accent-bg-color;
            color: #222222;
          }

          switch {
            background-color: #313244;
            border-color: transparent;
          }

          switch:checked {
            background-color: @accent-bg-color;
          }

          switch slider {
            background-color: white;
            border-color: transparent;
          }

          /* Sliders / progress bars */
          scale trough {
            background-color: #313244;
            border: none;
          }

          scale highlight {
            background-color: @accent-bg-color;
          }

          scale slider {
            background-color: #cdd6f4;
            border-color: @borders;
          }

          progressbar trough {
            background-color: #313244;
          }

          progressbar progress {
            background-color: @accent-bg-color;
          }

          /* Tooltips / separators / frames / statusbar */
          tooltip, tooltip.background {
            background-color: #1e1e2e;
            color: #cdd6f4;
            border-color: transparent;
          }

          tooltip decoration,
          window.background.tooltip decoration {
            box-shadow: none;
          }

          separator {
            background-color: @borders;
            min-width: 1px;
            min-height: 1px;
          }

          frame > border, frame border {
            border-color: @borders;
          }

          statusbar {
            background-color: #1e1e2e;
            color: #cdd6f4;
          }

          /* Links, spinners, selection */
          label.link, link {
            color: @accent-bg-color;
          }

          label.link:visited, link:visited {
            color: mix(@accent-bg-color, black, 0.9);
          }

          spinner {
            color: @accent-bg-color;
          }

          selection, *:selected {
            background-color: @accent-bg-color;
            color: #222222;
          }

          /* 19. Info bars / state colors  */
          infobar.info, infobar.question { background-color: @accent-bg-color; color: #222222; }
          infobar.warning                { background-color: @warning-color;  color: #11111b; }
          infobar.error                  { background-color: @error-color;    color: #222222; }

          separator {
            background: mix(currentColor,#1e1e2e,0.85);
            min-width: 1px;
            min-height: 1px;
          }

          /* Other */
          .welcome, actionbar, .table-header {
            background-color: #1e1e2e;
          }
        '';
        gtk4 = {
          iconTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
          };
          extraCss = ''
            :root {
              --window-bg-color: #1e1e2e;
              --window-fg-color: #cdd6f4;

              /* View styling */
              --view-bg-color: #1e1e2e;
              --view-fg-color: #cdd6f4;

              /* Header bar */
              --headerbar-bg-color: #181825;
              --headerbar-backdrop-color: #181825;
              --headerbar-fg-color: #cdd6f4;

              /* Popovers and dialogs */
              --popover-bg-color: #1e1e2e;
              --popover-fg-color: #cdd6f4;

              --dialog-bg-color: var(--popover-bg-color);
              --dialog-fg-color: var(--popover-fg-color);

              /* Cards and sidebars */
              --card-bg-color: #2f3042;
              --card-fg-color: #cdd6f4;

              --sidebar-bg-color: #181825;
              --sidebar-fg-color: #cdd6f4;
              --sidebar-backdrop-color: var(--sidebar-bg-color);
              --sidebar-border-color: #313244;

              --secondary-sidebar-bg-color: var(--sidebar-bg-color);
              --secondary-sidebar-fg-color: var(--sidebar-fg-color);
              --secondary-sidebar-backdrop-color: var(--sidebar-backdrop-color);
              --secondary-sidebar-border-color: var(--sidebar-border-color);

              /* Catppuccin accent colors */
              --blue-1: #89b4fa;
              --blue-2: #74c7ec;
              --blue-3: #89dceb;
              --blue-4: #94e2d5;
              --blue-5: #b4befe;

              --green-1: #a6e3a1;
              --green-2: #94e2d5;
              --green-3: #89dceb;
              --green-4: #74c7ec;
              --green-5: #89b4fa;

              --yellow-1: #f9e2af;
              --yellow-2: #fab387;
              --yellow-3: #f9e2af;
              --yellow-4: #f38ba8;
              --yellow-5: #eba0ac;

              --orange-1: #fab387;
              --orange-2: #f38ba8;
              --orange-3: #eba0ac;
              --orange-4: #f9e2af;
              --orange-5: #a6e3a1;

              --red-1: #f38ba8;
              --red-2: #eba0ac;
              --red-3: #f5c2e7;
              --red-4: #f2cdcd;
              --red-5: #f5e0dc;

              --purple-1: #cba6f7;
              --purple-2: #b4befe;
              --purple-3: #f5c2e7;
              --purple-4: #f2cdcd;
              --purple-5: #f5e0dc;

              --brown-1: #585b70;
              --brown-2: #6c7086;
              --brown-3: #7f849c;
              --brown-4: #9399b2;
              --brown-5: #bac2de;

              --light-1: #cdd6f4;
              --light-2: #a6adc8;
              --light-3: #bac2de;
              --light-4: #89b4fa;
              --light-5: #6c7086;

              --dark-1: #313244;
              --dark-2: #45475a;
              --dark-3: #585b70;
              --dark-4: #181825;
              --dark-5: #11111b;

              --active-toggle-bg-color: var(--window-fg-color);
              --active-toggle-fg-color: var(--window-bg-color);
            }

            toast {
              background-color: var(--window-bg-color);
              color: var(--window-fg-color);
            }

            .inline {
              background-color: rgba(0, 0, 0, 0);
            }


            @define-color accent_bg_color #b4befe;
            @define-color accent_fg_color #222222;
          '';
        };
      };

      home.pointerCursor = lib.mkDefault {
        enable = true;
        name = "AOSP-Cursors";
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.aosp-cursors;
        size = 18;
        hyprcursor = {
          enable = true;
          size = 18;
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
