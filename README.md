# nixos-files
files for my nixos-installation. DO NOT USE WORK IN PROGRESS!

BTW If you for some reason use this at this point. Use your own hardware configuration, bc this hardware configuration is for my laptop I'm testing on so this would (maybe) break your installation if you use it.

If you want to change your username. Change it in flake.nix and in configuration.nix

To make wlogout (and maybe other programs in the future work) put your nixos-files in your home folder so ~/nixos-files

**Distrobox**

I added some programs via distrobox like the thorium-browser. I will try to keep it that my system keeps working without needing the distrobox programs, but if you want the full setup you can use the arch-snapshot.tar.xz file (that is split up in distrobox/arch-snapshot. I will try to keep it up to date.

To install it:
- Go to correct directory
`cd ~/nixos-files/distrobox/arch-snapshot`

- Join the files together
`cat arch-part-* > arch-snapshot.tar.xz`

- Decompress xz file
`unxz arch-snapshot.tar.xz`

- Load into podman
`podman load -i arch-snapshot.tar`

- Create a new distrobox
`distrobox create --name arch --image arch-snapshot`

- Enter distrobox to set it up
`distrobox enter arch`

---

## Elo Touch Solutions - MT USB Touchscreen Driver

`pkgs/elo-mt-usb-driver/` packages Elo's old proprietary Linux MT USB driver
(v4.5.0.11, vendor binary blob) as a NixOS module, since Elo never shipped
a native Linux package and support for this hardware upstream doesn't exist.

**Usage:**

```nix
imports = [ ./pkgs/elo-mt-usb-driver/module.nix ];

services.elo-mt-usb = {
  enable = true;
  mode = "mtdigitizer"; # or "stdigitizer" / "absmouse", see module.nix
  configText = ''
    # Elo touch driver preset configuration
    #FOR VID=03eb PID=8a6e SN=<your-serial> SET INT_NUM=2
  '';
};
```

**Notes:**
- Only tested against an IntelliTouch (SAW) dual-touch controller. The
  driver package also lists TouchPro PCAP controllers as supported, but
  I can't confirm PCAP behavior since I don't own that hardware variant.
- SAW hardware is physically limited to 2 simultaneous touch points,
  this is a sensing-technology limit, not a driver limitation, so don't
  expect >2 fingers to ever work regardless of driver tweaks.
- The binary has several paths hardcoded into it at compile time
  (`/etc/opt/elo-mt-usb/config.txt`, `/var/log/elo-mt-usb/`,
  `/dev/elo-mt-usb/*_fifo`). The module works around this with
  `environment.etc`, `systemd.tmpfiles.rules`, and an `ExecStartPre`
  script rather than trying to relocate the binary's own paths.
- Unfree, vendor-redistributed binary; fetched at build time from
  Elo's own download URL, not mirrored in this repo. If that URL ever
  moves, the fetch will break; there's no fallback mirror yet.

---

## Brother MFC-6490CW Printer Driver

`pkgs/mfc6490cw-driver.nix` packages Brother's LPR + CUPS wrapper driver
for the MFC-6490CW; an old, unmaintained vendor `.deb` repackaged for
Nix. There's an [open nixpkgs PR](https://github.com/NixOS/nixpkgs/pull/512956)
for this that's been sitting without a reviewer since April 2026, so
until that lands (if ever), it lives here.

**Usage**, as a flake input pointing at this repo's branch:

```nix
# in your flake inputs
brother-mfc6490cw-src = {
  url = "github:XanderTheDev/nixpkgs/brother-mfc6490cw";
};
```

```nix
# wherever you configure printing
let
  brotherPkgs = import inputs.brother-mfc6490cw-src {
    system = system;
    config.allowUnfree = true;
  };
in {
  services.printing = {
    enable = true;
    drivers = [ brotherPkgs.brother-mfc6490cw ];
  };

  hardware.printers.ensurePrinters = [{
    name = "Brother_MFC-6490CW";
    location = "Home";
    deviceUri = "socket://<your-printer-ip>";
    model = "brmfc6490cw.ppd";
  }];
}
```

**Notes:**
- Paper size is hardcoded to A4 (see the `sed` calls in the derivation).
  I couldn't get paper-format switching working reliably through the
  Brother wrapper scripts, and A4 covers the common case, so I didn't
  chase it further.
- Unfree, vendor-redistributed binary (Brother's own `.deb` packages),
  same caveat as the Elo driver above: fetched at build time from
  Brother's download URL, not mirrored here.

---
