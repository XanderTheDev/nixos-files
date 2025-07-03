{ stdenv, lib }:

stdenv.mkDerivation {
  name = "brother-mfc6490cw-cupsfilter";
  src = ./printer-drivers; # adjust path relative to this file

  installPhase = ''
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model
    cp $src/brlpdwrappermfc6490cw $out/lib/cups/filter/
    cp $src/brmfc6490cw.ppd $out/share/cups/model/
    chmod +x $out/lib/cups/filter/brlpdwrappermfc6490cw
  '';
}
