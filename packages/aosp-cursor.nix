{ ... }: {
  perSystem =
    { pkgs, ... }:
    {
      packages.aosp-cursors = pkgs.callPackage (
        {
          stdenv,
          fetchFromGitHub,
          bun,
          kdePackages,
          writableTmpDirAsHomeHook,
          xcursorgen,
        }:
        stdenv.mkDerivation (finalAttrs: {
          pname = "aosp-cursors";
          version = "1.3.1";
          src = fetchFromGitHub {
            owner = "Tech-Tac";
            rev = "554015d";
            repo = "aosp-cursors";
            hash = "sha256-jUkIhO5wkUj+cEd/ieqTmkbhCUgWDjNZ96ii5/4/Pi4=";
          };
          dontWrapQtApps = true;
          nativeBuildInputs = [
            bun
            kdePackages.breeze
            xcursorgen
          ];

          nodeModules = stdenv.mkDerivation {
            pname = "${finalAttrs.pname}-node_modules";
            inherit (finalAttrs) src version;

            nativeBuildInputs = [
              bun
              writableTmpDirAsHomeHook
            ];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild

              bun install \
                --cpu="*" \
                --frozen-lockfile \
                --ignore-scripts \
                --no-progress \
                --os="*"

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp -r node_modules $out/node_modules

              runHook postInstall
            '';

            outputHash = "sha256-VREKyWpbxOWcYdxRHRnXhArcRxHyh62o5zbFlPZTDQo=";
            outputHashAlgo = "sha256";
            outputHashMode = "recursive";
          };

          buildPhase = ''
            cp -r ${finalAttrs.nodeModules}/node_modules .
                chmod -R +w node_modules
                patchShebangs --build node_modules
            bun run build_theme.js
          '';
          # src = ../cursor-theme;
          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/icons/AOSP-Cursors
            bun run build_theme.js
            cp -r output/linux/* $out/share/icons/AOSP-Cursors
            runHook postInstall
          '';
        })
      ) { };
    };
}
