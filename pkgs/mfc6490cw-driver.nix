{
  stdenvNoCC,
  lib,
  patchelf,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  pkgsi686Linux,
  coreutils,
  ghostscript,
  gnugrep,
  gnused,
  a2ps,
  file,
  psutils,
  which,
}:

let
  model   = "mfc6490cw";
  version = "1.1.2-2";
  reldir  = "usr/local/Brother/Printer/${model}";
in

stdenvNoCC.mkDerivation {
  pname   = "brother-${model}";
  inherit version;

  srcLpr = fetchurl {
    url    = "https://download.brother.com/welcome/dlf006180/${model}lpr-${version}.i386.deb";
    sha256 = "1p33aal3dv3r03v9nbafrzx2bhij34hrsg2d71kwm738a8n18vnj";
  };
  srcCups = fetchurl {
    url    = "https://download.brother.com/welcome/dlf006182/${model}cupswrapper-${version}.i386.deb";
    sha256 = "1msj1hz7i1jn806gkd4nahwdc4rff030fzp37pfdxg9hjc88vfxi";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
    patchelf
    # Needed so autoPatchelfHook can resolve 32-bit ELF dependencies
    pkgsi686Linux.glibc
    pkgsi686Linux.gcc.cc.lib
  ];

  buildInputs = [
    pkgsi686Linux.glibc
    pkgsi686Linux.gcc.cc.lib
  ];

  dontUnpack = true;

  installPhase =
    let
      filterBinPath = lib.makeBinPath [
        coreutils ghostscript gnugrep gnused which a2ps file psutils
      ];
      cupsBinPath = lib.makeBinPath [
        coreutils ghostscript gnugrep gnused psutils
      ];
      filterScript  = "$out/${reldir}/lpd/filter${model}";
      wrapperScript = "$out/${reldir}/cupswrapper/cupswrapper${model}";
      lpdWrapper    = "$out/lib/cups/filter/brlpdwrapper${model}";
      ppd           = "$out/share/cups/model/br${model}.ppd";
      rcFile        = "$out/${reldir}/inf/br${model}rc";
    in
    ''
      runHook preInstall

      mkdir -p lpr cups
      dpkg-deb -x "$srcLpr"  lpr
      dpkg-deb -x "$srcCups" cups

      mkdir -p "$out/${reldir}"/{lpd,cupswrapper,inf}
      mkdir -p "$out"/{share/cups/model,lib/cups/filter}

      cp -r lpr/${reldir}/. "$out/${reldir}/"
      cp -r cups/${reldir}/. "$out/${reldir}/"

      # Brother's rc file ships with Letter as default. Since the nix store
      # is read-only, brcupsconfpt1 cannot update it at runtime, so we patch
      # it at build time instead.
      sed -i 's/PaperType=Letter/PaperType=A4/' "${rcFile}"

      # Patch the LPR filter to find its Brother tree in the nix store
      substituteInPlace "${filterScript}" \
        --replace-warn "BR_PRT_PATH=" "BR_PRT_PATH=\"$out/${reldir}\" #"
      chmod +x "${filterScript}"
      wrapProgram "${filterScript}" \
        --prefix PATH : "${filterBinPath}:$out/${reldir}/cupswrapper"

      # Patch the CUPS wrapper script and run it to generate the PPD
      # and brlpdwrapper filter. The "lpinfo: not found" error is harmless.
      substituteInPlace "${wrapperScript}" \
        --replace-warn '/usr/local/Brother/''${device_model}/''${printer_model}/lpd/filter''${printer_model}' \
                       "${filterScript}" \
        --replace-warn '/usr/local/Brother/''${device_model}/''${printer_model}' \
                       "$out/${reldir}" \
        --replace-warn '/usr/share/cups/model'   "$out/share/cups/model"  \
        --replace-warn '/usr/share/ppd'          "$out/share/ppd"         \
        --replace-warn '/usr/lib/cups/filter'    "$out/lib/cups/filter"   \
        --replace-warn '/usr/lib64/cups/filter'  "$out/lib64/cups/filter" \
        --replace-warn '/usr/lib/cups/backend'   "$out/lib/cups/backend"  \
        --replace-warn '/usr/lib64/cups/backend' "$out/lib64/cups/backend"\
        --replace-warn '/usr/bin/psnup'          '${psutils}/bin/psnup'
      chmod +x "${wrapperScript}"
      PATH="${coreutils}/bin:${gnugrep}/bin:${gnused}/bin:${ghostscript}/bin" \
        "${wrapperScript}" || true

      # Fix PPD defaults: Brother ships Letter-sized values; correct them
      # to standard A4 dimensions (595x842 PostScript points).
      sed -i \
        -e 's/\*DefaultPageSize: Letter/*DefaultPageSize: A4/' \
        -e 's/\*DefaultPageRegion: Letter/*DefaultPageRegion: A4/' \
        -e 's/\*PaperDimension A4\/A4:.*"585 829"/*PaperDimension A4\/A4:\t\t\t\t"595 842"/' \
        -e 's/\*ImageableArea A4\/A4:.*"9 9 576 820"/*ImageableArea A4\/A4:\t\t\t\t\t"9 9 586 833"/' \
        "${ppd}"

      if [ -f "${lpdWrapper}" ]; then
        wrapProgram "${lpdWrapper}" \
          --prefix PATH : "${cupsBinPath}:$out/${reldir}/cupswrapper"
      else
        echo "WARNING: ${lpdWrapper} was not generated — something went wrong with the cupswrapper script"
        exit 1
      fi

      runHook postInstall
    '';

  # autoPatchelfHook doesn't reach binaries outside the standard output
  # directories, so we patch the 32-bit Brother binaries manually.
  postFixup =
    let
      interp = "${pkgsi686Linux.glibc}/lib/ld-linux.so.2";
      rpath  = lib.makeLibraryPath [ pkgsi686Linux.glibc pkgsi686Linux.gcc.cc.lib ];
      brotherBins = [
        "${reldir}/lpd/br${model}filter"
        "${reldir}/cupswrapper/brcupsconfpt1"
      ];
    in
    ''
      ${lib.concatMapStrings (bin: ''
        patchelf \
          --set-interpreter "${interp}" \
          --set-rpath "${rpath}" \
          "$out/${bin}"
      '') brotherBins}
    '';

  meta = with lib; {
    description = "Brother MFC-6490CW printer driver (LPR + CUPS wrapper)";
    homepage    = "https://www.brother.com/";
    license     = licenses.unfree;
    platforms   = [ "x86_64-linux" "i686-linux" ];
    maintainers = [ ];
  };
}
