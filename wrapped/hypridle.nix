{ self, inputs, ... }:
{
  flake.hypridle = inputs.wrapper-modules.lib.wrapModule (
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    let
      /*
         from:
         https://github.com/nix-community/home-manager/blob/8a423e444b17dde406097328604a64fc7429e34e/modules/lib/generators.nix
      */
      toHyprconf =
        {
          attrs,
          indentLevel ? 0,
          importantPrefixes ? [ "$" ],
        }:
        let
          inherit (lib)
            all
            concatMapStringsSep
            concatStrings
            concatStringsSep
            filterAttrs
            foldl
            generators
            hasPrefix
            isAttrs
            isList
            mapAttrsToList
            replicate
            attrNames
            ;

          initialIndent = concatStrings (replicate indentLevel "  ");

          toHyprconf' =
            indent: attrs:
            let
              isImportantField =
                n: _: foldl (acc: prev: if hasPrefix prev n then true else acc) false importantPrefixes;
              importantFields = filterAttrs isImportantField attrs;
              withoutImportantFields = fields: removeAttrs fields (attrNames importantFields);

              allSections = filterAttrs (_n: v: isAttrs v || isList v) attrs;
              sections = withoutImportantFields allSections;

              mkSection =
                n: attrs:
                if isList attrs then
                  let
                    separator = if all isAttrs attrs then "\n" else "";
                  in
                  (concatMapStringsSep separator (a: mkSection n a) attrs)
                else if isAttrs attrs then
                  ''
                    ${indent}${n} {
                    ${toHyprconf' "  ${indent}" attrs}${indent}}
                  ''
                else
                  toHyprconf' indent { ${n} = attrs; };

              mkFields = generators.toKeyValue {
                listsAsDuplicateKeys = true;
                inherit indent;
              };

              allFields = filterAttrs (_n: v: !(isAttrs v || isList v)) attrs;
              fields = withoutImportantFields allFields;
            in
            mkFields importantFields
            + concatStringsSep "\n" (mapAttrsToList mkSection sections)
            + mkFields fields;
        in
        toHyprconf' initialIndent attrs;
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        settings = lib.mkOption {
          type =
            with lib.types;
            let
              valueType =
                nullOr (oneOf [
                  bool
                  int
                  float
                  str
                  path
                  (attrsOf valueType)
                  (listOf valueType)
                ])
                // {
                  description = "Hypridle configuration value";
                };
            in
            valueType;
          default = { };
          example = lib.literalExpression ''
            general {
                lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
                before_sleep_cmd = loginctl lock-session    # lock before suspend.
                after_sleep_cmd = hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
            }

            listener {
                timeout = 150                                # 2.5min.
                on-timeout = brightnessctl -s set 10         # set monitor backlight to minimum, avoid 0 on OLED monitor.
                on-resume = brightnessctl -r                 # monitor backlight restore.
            }

            # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
            listener {
                timeout = 150                                          # 2.5min.
                on-timeout = brightnessctl -sd rgb:kbd_backlight set 0 # turn off keyboard backlight.
                on-resume = brightnessctl -rd rgb:kbd_backlight        # turn on keyboard backlight.
            }
          '';
          description = ''
            Configuration of Hypridle
            See <https://wiki.hypr.land/Hypr-Ecosystem/hypridle/>
          '';
        };
        "hypridle.conf" = lib.mkOption {
          type = wlib.types.file {
            path = lib.mkOptionDefault config.constructFiles.generatedConfig.path;
            content = (
              lib.optionalString (config.settings != { }) (toHyprconf {
                inherit (config) importantPrefixes;
                attrs = config.settings;
              })
              + lib.optionalString (config.extraConfig != "") config.extraConfig
            );
          };
          default = { };
          description = ''
            Hypridle configuration file.
          '';
        };
        extraConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          example = ''
            source /path/to/extra.conf
          '';
          description = ''
            Extra configuration lines appended to the end of the Hypridle configuration file.
          '';
        };
        importantPrefixes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "$"
          ];
          example = [
            "$"
          ];
        };
      };

      config.package = lib.mkDefault pkgs.hypridle;
      config.flags."-c" = config."hypridle.conf".path;

      config.constructFiles.generatedConfig = {
        content = config."hypridle.conf".content;
        relPath = "/${config.binName}.conf";
      };

      config.meta = {
        maintainers = [ "Arc" ];
        platforms = lib.platforms.linux;
      };
    }
  );

  perSystem =
    { inputs', pkgs, ... }:
    {
      packages.hypridle = self.hypridle.wrap {
        inherit pkgs;
        package = inputs'.hypridle.packages.default;
        settings = {
          general = {
            lock_cmd = "loginctl lock-session";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "niri msg action power-on-monitors";
            inhibit_sleep = 3;
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "niri msg action power-off-monitors";
              on-resume = "niri msg action power-on-monitors";
            }
          ];
        };
      };
    };
}
