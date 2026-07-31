{ lib, stdenv, fetchurl, autoPatchelfHook, libX11, libXinerama, libXpm, libXt, libusb1, motif }:

stdenv.mkDerivation rec {
  pname = "elo-mt-usb-driver";
  version = "4.5.0.11";

  src = fetchurl {
    url = "https://downloads.elotouch.com/Downloads/Touch%20Driver/Linux/AMD64/${version}/SW-0059764_Elo_Linux_MT_USB_Driver_v${version}_x86_64.tgz";
    sha256 = "03n2c2rjw9f2923xplnwh61pa1v0ax92vcx6zyslm5jx4gksgqv2";
  };

  # NOTE: assumes the tarball's top-level entry is literally "bin-mt-usb"
  # (matches the vendor readme's `cp -r ./bin-mt-usb/ /etc/opt/elo-mt-usb`).
  # If the build fails to find sourceRoot, run:
  #   tar tzf <path-to-tgz> | head
  # and adjust this to match the real top-level directory name.
  sourceRoot = "bin-mt-usb";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libusb1                 # elomtusbd
    libX11              # elova, cpl
    libXinerama         # elova, cpl
    libXpm               # cpl
    libXt                 # cpl
    motif                     # cpl -> provides libXm.so.4 (free Motif reimpl)
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 elomtusbd "$out/bin/elomtusbd"
    install -Dm755 elova     "$out/bin/elova"
    install -Dm755 cplcmd    "$out/bin/cplcmd"
    install -Dm755 cpl       "$out/bin/cpl"

    install -Dm444 config.txt          "$out/share/elo-mt-usb/config.txt.example"
    install -Dm444 99-elotouch.rules   "$out/share/elo-mt-usb/99-elotouch.rules"
    install -Dm444 readme.txt          "$out/share/doc/elo-mt-usb/readme.txt"

    runHook postInstall
  '';

  # elomtusbd is only meant to be started via the loader script /
  # systemd unit, never run interactively -- the NixOS module below
  # handles that. autoPatchelfHook rewrites the ELF interpreter/rpath
  # for all four binaries so they resolve libs from the Nix store.

  meta = with lib; {
    description = "Elo Touch Solutions Multi-Touch USB Linux driver (repackaged binary blob, v${version})";
    homepage = "https://www.elotouch.com";
    license = licenses.unfree; # vendor binary, see GA000068 EULA.pdf in the original tarball
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
