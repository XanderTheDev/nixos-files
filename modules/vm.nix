{ config, pkgs, ... }:

{
	
	# Setting up libvirtd
	virtualisation.libvirtd = {
  		enable = true;
  		qemu = {
    			package = pkgs.qemu_kvm;
    			runAsRoot = true;
    			swtpm.enable = true;
  		};
	};
	
	# Making USB transfer possible in VM
	virtualisation.spiceUSBRedirection.enable = true;

	# Enabling spice
	services.spice-vdagentd.enable = true;
	
	# Packages for using VM
	environment.systemPackages = with pkgs; [
		virt-manager
		virt-viewer
		spice spice-gtk
		spice-protocol
                virtio-win
		win-spice
	];

}
