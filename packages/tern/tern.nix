{ ... }:
let
  sources = {
    x86_64-linux = {
      file = ./Tern-0.9.11-linux-x86_64.tar.gz;
      hash = "ad61cf1a2cf897dfe57ae0bf2e64a9e8c2529360c14dce251850be28e760dbe7";
    };
    aarch64-linux = {
      file = "./Tern-0.9.11-linux-arm64.tar.gz";
      hash = "cee375135ce4091f42e6e10847aea3195d48aeb348b2f40911c20276c4430e29";
    };
  };
in
{

  perSystem =
    { pkgs, system, ... }:
    {
      packages.tern = pkgs.callPackage (
        {
          stdenv,
          lib,
          webkitgtk_4_1,
          libglvnd,
          vulkan-loader,
          wayland,
          libxkbcommon,
          libxcb,
          glib,
          gtk3,
          libwpe,
          libwpe-fdo,
          pipewire,
          zenity,
          perf,
          makeWrapper,
          patchelf,
          binutils,
          writers,
        }:
        stdenv.mkDerivation (finalAttrs: {
          pname = "tern";
          version = "0.9.11";

          src = (sources.${system}).file;

          dontStrip = true;

          runtimeLibs = [
            stdenv.cc.cc.lib
            vulkan-loader
            libglvnd
            wayland
            libxkbcommon
            libxcb
            glib
            gtk3
            webkitgtk_4_1
            libwpe
            libwpe-fdo
            # tern dlopens libpipewire for screen sharing itself, so the library has
            # to be reachable, not just the daemon.
            pipewire
            # tern dlopens libpulse-simple.so.0 itself as of 0.7.0 (PulseAudio simple
            # API), so it has to be reachable too.
          ];

          runtimePrograms = [
            zenity
            glib.bin
            perf
          ];

          webkitRuntimeEnv = with pkgs; [
            "--prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules"
            "--prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
            "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.getLib gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
          ];

          runtimeLibraryPath = lib.makeLibraryPath finalAttrs.runtimeLibs;

          nuConfig =
            writers.writeText "tern-nu-config.nu"

              ''
                source ($nu.default-config-dir | path join "config.nu")

                $env.config.hooks.pre_execution = (
                  $env.config.hooks.pre_execution? | default [] | append [
                    {||
                      try {
                        let line = (commandline)
                        if not ($line | is-empty) {
                          # POSIX single-quoting: a quote inside the word closes,
                          # escapes and reopens it, so Tern reads one word per
                          # argument back. Built from code points, so neither this
                          # file nor the Nix string carries the backslash literally.
                          let sq = "\u{27}"
                          let esc = ($sq + "\u{5c}" + $sq + $sq)
                          # Tern claims a command from the alias-expanded line when the
                          # shell reports one (its own integrations send both fields);
                          # nushell reports the typed words, so expand the first word
                          # here when it names an alias -- `ll` then reaches Tern's own
                          # ls family as `eza -la`, which it can read.
                          let head = ($line | split row " " | first)
                          let hit = (try { scope aliases | where name == $head | get expansion? } catch { [] })
                          let rest = ($line | str replace --regex "^[^ ]+" "")
                          let full = (if ($hit | is-empty) { $line } else { ($hit | first) + $rest })
                          let typed = ($sq + ($line | str replace --all -- $sq $esc) + $sq)
                          let expanded = ($sq + ($full | str replace --all -- $sq $esc) + $sq)
                          print -n $"\u{1b}]133;C;cmdline=($typed);cmdline_expanded=($expanded)\u{7}"
                        }
                      } catch { }
                    }
                  ]
                )
              '';

          nativeBuildInputs = [
            makeWrapper
            patchelf
            binutils
          ];

          dontConfigure = true;
          dontBuild = true;
          dontPatchELF = true;

          installPhase = ''
            runHook preInstall

            appDir="$out/opt/tern"
            mkdir -p "$appDir" "$out/bin"
            cp -a . "$appDir/"
            chmod -R u+w "$appDir"

            strip --strip-unneeded "$appDir/tern" || true

            rpath="${finalAttrs.runtimeLibraryPath}:\''$ORIGIN/../lib:\''$ORIGIN"
            patchelf --set-rpath "$rpath" "$appDir/tern"
            patchelf --set-interpreter "${pkgs.stdenv.cc.bintools.dynamicLinker}" "$appDir/tern"

            makeWrapper "$appDir/tern" "$out/bin/tern" \
              --prefix LD_LIBRARY_PATH : "${finalAttrs.runtimeLibraryPath}" \
              --prefix PATH : "${lib.makeBinPath finalAttrs.runtimePrograms}" \
              ${lib.concatStringsSep " " finalAttrs.webkitRuntimeEnv}

            runHook postInstall
          '';

          meta = {
            description = "Multiplexing terminal with webview UI";
            homepage = "https://tern.sh";
            # license = lib.licenses.unfreeRedistributable;
            sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
            mainProgram = "tern";
          };
        })
      ) { };
    };
}
