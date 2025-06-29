{ config, pkgs, ... }:

{

	virtualisation.libvirtd = {
  		enable = true;
  		qemu = {
    			package = pkgs.qemu_kvm;
    			runAsRoot = true;
    			swtpm.enable = true;
    			ovmf = {
      				enable = true;
      				packages = [ pkgs.OVMFFull.fd ];
    			};
  		};
	};
	
	virtualisation.spiceUSBRedirection.enable = true;

	services.spice-vdagentd.enable = true;
	
	environment.systemPackages = with pkgs; [
		virt-manager
		virt-viewer
		spice spice-gtk
		spice-protocol
		win-virtio
		win-spice
	];

}
