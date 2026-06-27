{ inputs, lib, config, pkgs, ... }: {

  systemd.services.NetworkManager-wait-online.enable = false;

  systemd.services.docker.wants = lib.mkForce [];
  systemd.services.docker.after = lib.mkForce [ "network.target" ];
  systemd.services.docker.wantedBy = lib.mkForce [];
  systemd.services.libvirtd.wantedBy = lib.mkForce [];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  services.openssh.enable = false;

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    LogLevel = "notice";
    DefaultDependencies = "yes";
  };

  boot.plymouth = {
    enable = true;
  };

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  boot.loader.timeout = lib.mkDefault 0;

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "start-hyprland > /dev/null 2>&1 && plymouth quit";
        user = "xander";
      };
      default_session = initial_session;
    };
  };
}
