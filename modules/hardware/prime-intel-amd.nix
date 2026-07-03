{ pkgs, ... }: {
  # NixOS has no dedicated "prime" option for Intel+AMD hybrid graphics
  # (hardware.nvidia.prime is Nvidia-only). Both drivers load; switch the
  # active GPU per-app with `amd-offload <command>` (DRI_PRIME=1 wrapper).
  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "amd-offload" ''
      export DRI_PRIME=1
      exec "$@"
    '')
  ];
}
