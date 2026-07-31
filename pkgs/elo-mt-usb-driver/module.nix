{ config, lib, pkgs, ... }:

let
  cfg = config.services.elo-mt-usb;
  elo-mt-usb-driver = pkgs.callPackage ./elo-mt-usb-driver.nix { };

  # Replaces eloCreateFifo.sh. NOT done via systemd.tmpfiles.rules' "p"
  # type: pipes under /dev are only created by
  # systemd-tmpfiles-setup-dev.service, which runs once at boot and is
  # *not* re-triggered by `nixos-rebuild switch` on a running system --
  # so the daemon would fail with "No such file or directory" on
  # cmd_fifo until the next reboot. Recreating them as an ExecStartPre,
  # like the original script did, makes this work on every service
  # start regardless of boot state.
  elo-mt-usb-create-fifo = pkgs.writeShellScript "elo-mt-usb-create-fifo" ''
    set -e
    mkdir -p /dev/elo-mt-usb
    rm -f /dev/elo-mt-usb/cmd_fifo /dev/elo-mt-usb/rsp_fifo
    mkfifo -m 0776 /dev/elo-mt-usb/cmd_fifo
    mkfifo -m 0776 /dev/elo-mt-usb/rsp_fifo
  '';
in
{
  options.services.elo-mt-usb = {
    enable = lib.mkEnableOption "Elo Multi-Touch USB touchscreen driver";

    mode = lib.mkOption {
      type = lib.types.enum [ "mtdigitizer" "stdigitizer" "absmouse" ];
      default = "mtdigitizer";
      description = ''
        Input mode passed to elomtusbd:
          mtdigitizer - full multitouch protocol (default, needs MT-aware apps)
          stdigitizer - single-touch digitizer events (legacy apps/kernels)
          absmouse    - plain absolute mouse events (oldest fallback)
      '';
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = ''
        # Elo touch driver preset configuration
      '';
      example = ''
        # Elo touch driver preset configuration
        #FOR VID=03eb PID=8a6e SN=K17R006813 SET INT_NUM=2
      '';
      description = ''
        Contents written to /etc/opt/elo-mt-usb/config.txt.
        This path is hardcoded inside the elomtusbd binary itself
        (confirmed via `strings`), so it cannot be relocated into
        the Nix store -- it has to be a real file at that exact path.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # elomtusbd talks to /dev/uinput to synthesize input events.
    boot.kernelModules = [ "uinput" ];

    # Hardcoded config path baked into the binary. Managed declaratively
    # here instead of the old rc.local-copied file.
    environment.etc."opt/elo-mt-usb/config.txt".text = cfg.configText;

    # Writable dirs the binary expects at fixed, hardcoded paths.
    # (These live under /etc and /var, which nixos-rebuild switch does
    # re-apply via systemd-tmpfiles-resetup.service on every activation.)
    systemd.tmpfiles.rules = [
      "d /etc/opt/elo-mt-usb/ConfigData 0775 root input -"
      "d /var/log/elo-mt-usb 0755 root input -"
    ];

    # Replaces 99-elotouch.rules (originally MODE=0666 for anyone) with
    # group-based access via the "input" group, plus uinput permissions
    # that NixOS doesn't grant by default.
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", TAG+="uaccess"

      # Elo Touch Solutions vendor IDs, from the original 99-elotouch.rules
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e7", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTR{idVendor}=="0eef", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTR{idVendor}=="2149", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTR{idVendor}=="1ff7", MODE="0660", GROUP="input"
    '';

    systemd.services.elo-mt-usb = {
      description = "Elo Multi-Touch USB touchscreen driver";
      after = [ "systemd-udevd.service" "systemd-tmpfiles-setup-dev.service" ];
      wants = [ "systemd-tmpfiles-setup-dev.service" ];
      wantedBy = [ "graphical.target" ];

      serviceConfig = {
        # elomtusbd daemonizes itself (forks and the parent exits), same
        # as the original elo.service. If it misbehaves under systemd
        # (e.g. "Failed at step... /dev/elo-mt-usb" or unit stays
        # "activating" forever), switch this to Type = "simple" and
        # drop the ExecStartPre sleep below.
        Type = "forking";
        ExecStartPre = [
          "${elo-mt-usb-create-fifo}"
          "${pkgs.coreutils}/bin/sleep 1"
        ];
        ExecStart = "${elo-mt-usb-driver}/bin/elomtusbd --${cfg.mode}";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Puts elova/cplcmd/cpl on PATH for manual calibration and control
    # panel use (see usage notes below).
    environment.systemPackages = [ elo-mt-usb-driver ];
  };
}
